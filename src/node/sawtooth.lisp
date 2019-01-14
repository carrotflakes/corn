(defpackage corn.node.sawtooth
  (:use :cl
        :corn.node
        :corn.node.param
        :corn.parameters)
  (:import-from :alexandria
                :with-gensyms)
  (:export :make-sawtooth
           :sawtooth-frequency))
(in-package :corn.node.sawtooth)

#|..   ..   ..    |
 |. .. . .. . ..  |
 |.   ..   ..   ..|
 |#

(defstruct (sawtooth (:include node))
  (frequency (make-input :channels 1
                         :default-sample-1 0.0))
  (phase 0d0))

(defmethod node-parts ((sawtooth sawtooth))
  (with-gensyms (phase sample)
    (with-input-parts
        (bindings
         initialize
         update
         sample-1
         sample-2
         finalize)
        (sawtooth-frequency sawtooth)
    `(:bindings (,@bindings
                 (,phase (sawtooth-phase ,sawtooth))
                 (,sample 0.0))
      :initialize ,initialize
      :update (,@update
               (setf ,sample (float (- 1 (* ,phase 2)) 0.0)
                     ,phase (mod (+ ,phase (/ ,sample-1 *sampling-rate*)) 1)))
      :sample-1 ,sample
      :sample-2 ,sample
      :finalize (,@finalize
                 (setf (sawtooth-phase ,sawtooth) ,phase))))))
