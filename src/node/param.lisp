(defpackage corn.node.param
  (:use :cl
        :corn.parameters
        :corn.node
        :corn.event)
  (:import-from :alexandria
                :with-gensyms)
  (:export :make-param
           :param-value
           :param-set-value
           :param-linear-ramp))
(in-package :corn.node.param)

(defstruct (param (:include node (channels 1)))
  (value 0.0)
  (event-manager (make-event-manager)))

(defstruct (set-value (:include event))
  (value 0.0))
(defstruct (linear-ramp (:include event))
  (start-value 0.0)
  (end-value 0.0))

(declaim (inline param-event-value))
(defun param-event-value (event)
  (etypecase event
    (set-value
     (set-value-value event))
    (linear-ramp
     (let ((rate (/ (- *current-time* (event-time event)) (event-duration event))))
       (+ (* (linear-ramp-start-value event) (- 1.0 rate))
          (* (linear-ramp-end-value event) rate))))))

(defmethod node-parts ((param param))
  (with-gensyms (events value)
    `(:bindings ((,events (progn
                            (update (param-event-manager ,param) *current-time* *next-time*)
                            (event-manager-current-events (param-event-manager ,param))))
                 (,value (param-value ,param)))
      :initialize ()
      :update ((when (and ,events (<= (event-time (first ,events)) *current-time*))
                 (let ((event (first ,events)))
                   (setf ,value (param-event-value event))
                   (when (<= (event-end-time event) *current-time*)
                     (pop ,events)))))
      :sample-1 ,value
      ;:sample-2 ,value
      :finalize ((setf (param-value ,param) ,value)))))

(defun param-set-value (param &key time value)
  (push-event (param-event-manager param)
              (make-set-value :time time
                              :duration 0.0
                              :value value)))

(defun param-linear-ramp (param &key time duration start-value end-value)
  (push-event (param-event-manager param)
              (make-linear-ramp :time time
                                :duration duration
                                :start-value start-value
                                :end-value end-value)))
