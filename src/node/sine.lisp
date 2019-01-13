(defpackage corn.node.sine
  (:use :cl
        :corn.node
        :corn.node.param
        :corn.parameters)
  (:import-from :alexandria
                :with-gensyms)
  (:export :make-sine
           :sine-frequency))
(in-package :corn.node.sine)

(defstruct (sine (:include node))
  (frequency (make-input :channels 1
                         :default-sample-1 0.0))
  (phase 0d0))

(defmethod node-parts ((sine sine))
  (with-gensyms (phase sample)
    (with-input-parts
        (bindings
         initialize
         update
         sample-1
         sample-2
         finalize)
        (sine-frequency sine)
    `(:bindings (,@bindings
                 (,phase (sine-phase ,sine))
                 (,sample 0.0))
      :initialize ,initialize
      :update (,@update
               (setf ,sample (float (sin ,phase) 0.0))
               (incf ,phase (* (/ ,sample-1 *sampling-rate*) 2 pi)))
      :sample-1 ,sample
      :sample-2 ,sample
      :finalize (,@finalize
                 (setf (sine-phase ,sine) ,phase))))))
