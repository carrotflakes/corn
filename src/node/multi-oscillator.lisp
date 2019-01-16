(defpackage corn.node.multi-oscillator
  (:use :cl
        :corn.node
        :corn.node.param
        :corn.event-manager
        :corn.parameters)
  (:import-from :alexandria
                :with-gensyms)
  (:export :make-multi-oscillator
           :multi-oscillator-type
           :multi-oscillator-frequency
           :multi-oscillator-set-phase))
(in-package :corn.node.multi-oscillator)

(defstruct (multi-oscillator (:include node))
  (type :sine)
  (frequency (make-input :channels 1
                         :default-sample-1 0.0))
  (event-manager (make-event-manager))
  (phase 0d0))

(defstruct (set-phase (:include event))
  (phase 0d0))

(declaim (inline sample))
(defun sample (type phase)
  (ecase type
    (:sine
     (sin (* phase 2 pi)))
    (:square
     (if (< 0.5 phase) 1.0 -1.0))
    (:triangle
     (cond
       ((< phase 0.25) (* phase 4))
       ((< phase 0.75) (* (- 0.5 phase) 4))
       (t (* (- phase 1) 4))))
    (:sawtooth
     (- 1 (* phase 2)))))

(defmethod node-parts ((multi-oscillator multi-oscillator))
  (with-gensyms (type phase sample events)
    (with-input-parts
        (bindings
         initialize
         update
         sample-1
         sample-2
         finalize)
        (multi-oscillator-frequency multi-oscillator)
      (setf bindings
            (append bindings
                    `((,events (let ((event-manager
                                       (multi-oscillator-event-manager ,multi-oscillator)))
                                 (update event-manager *current-time* *next-time*)
                                 (event-manager-current-events event-manager)))))
            update
            (append update
                    `((when (and ,events (<= (event-time (first ,events)) *current-time*))
                        (setf ,phase (set-phase-phase (first ,events)))
                        (pop ,events)))))
      `(:bindings (,@bindings
                   (,type (multi-oscillator-type ,multi-oscillator))
                   (,phase (multi-oscillator-phase ,multi-oscillator))
                   (,sample 0.0))
        :initialize ,initialize
        :update (,@update
                 (setf ,sample (float (sample ,type ,phase) 0.0)
                       ,phase (mod (+ ,phase (/ ,sample-1 *sampling-rate*)) 1)))
        :sample-1 ,sample
        :sample-2 ,sample
        :finalize (,@finalize
                   (setf (multi-oscillator-phase ,multi-oscillator) ,phase))))))

(defun multi-oscillator-set-phase (multi-oscillator &key time phase)
  (push-event (multi-oscillator-event-manager multi-oscillator)
              (make-set-phase :time time
                              :duration 0.0
                              :phase phase)))
