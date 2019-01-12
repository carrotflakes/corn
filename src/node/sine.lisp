(defpackage corn.node.sine
  (:use :cl
        :corn.node
        :corn.parameters)
  (:import-from :alexandria
                :with-gensyms)
  (:export :make-sine))
(in-package :corn.node.sine)

(defstruct (sine (:include node))
  (frequency 440.0)
  (phase 0.0))

(defmethod node-parts ((sine sine))
  (with-gensyms (phase dphase sample)
    `(:bindings ((,phase (sine-phase ,sine))
                 (,dphase (float (* (/ (sine-frequency ,sine) *sampling-rate*) 2 pi)
                                 0.0))
                 (,sample 0.0))
      :initialize ()
      :update ((setf ,sample (sin ,phase))
               (incf ,phase ,dphase))
      :sample-1 ,sample
      :sample-2 ,sample
      :finalize ((setf (sine-phase ,sine) ,phase)))))
