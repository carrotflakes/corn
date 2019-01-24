(defpackage corn.node.param
  (:use :cl
        :corn.parameters
        :corn.node
        :corn.event-manager
        :queues)
  (:import-from :alexandria
                :with-gensyms)
  (:import-from :corn.util
                :interpolate-exponential-ramp)
  (:export :make-param
           :param-value
           :param-set-value
           :param-linear-ramp
           :param-exponential-ramp
           :param-set-target
           :param-get-value
           :param-cancel-and-hold))
(in-package :corn.node.param)

(defparameter *eps* 0.00001d0)

(defstruct (param (:include node (channels 1)))
  (value 0.0)
  (event-manager (make-event-manager)))

(defstruct (set-value (:include event))
  (value 0.0))
(defstruct (linear-ramp (:include event))
  (start-value 0.0)
  (end-value 0.0))
(defstruct (exponential-ramp (:include event))
  (start-value 0.0)
  (end-value 0.0))
(defstruct (set-target (:include event))
  (start-value 0.0)
  (target-value 0.0)
  time-constant)

(declaim (inline param-event-value))
(defun param-event-value (event time)
  (etypecase event
    (set-value
     (set-value-value event))
    (linear-ramp
     (let ((rate (/ (- time (event-time event)) (event-duration event))))
       (+ (* (linear-ramp-start-value event) (- 1.0 rate))
          (* (linear-ramp-end-value event) rate))))
    (exponential-ramp
     (let ((rate (/ (- time (event-time event)) (event-duration event))))
       (interpolate-exponential-ramp (exponential-ramp-start-value event)
                                     (exponential-ramp-end-value event)
                                     rate)))
    (set-target
     (+ (* (- (set-target-start-value event) (set-target-target-value event))
           (expt #.(- 1d0 (exp -1)) (/ (- time (event-time event))
                                       (set-target-time-constant event))))
        (set-target-target-value event)))))
; TODO faster

(defmethod node-parts ((param param))
  (with-gensyms (events value)
    `(:bindings ((,events (progn
                            (update (param-event-manager ,param) *current-time* *next-time*)
                            (event-manager-current-events (param-event-manager ,param))))
                 (,value (param-value ,param)))
      :initialize ()
      :update ((when (and ,events (<= (event-time (first ,events)) *current-time*))
                 (loop
                   while (and (second ,events)
                              (<= (event-time (second ,events)) *current-time*))
                   do (pop ,events))
                 (setf ,value (param-event-value (first ,events) *current-time*))
                 (loop
                   while (and ,events (<= (event-end-time (first ,events)) *current-time*))
                   do (pop ,events))))
      :sample-1 (float ,value 0.0)
      ;:sample-2 ,value
      :finalize ((setf (param-value ,param) ,value
                       (event-manager-current-events (param-event-manager ,param))
                       ,events)))))

(defun param-set-value (param &key time value)
  (push-event (param-event-manager param)
              (make-set-value :time time
                              :duration 0.0
                              :value value)))

(defun param-linear-ramp (param &key time duration start-value end-value)
  (push-event (param-event-manager param)
              (make-linear-ramp :time time
                                :duration (max *eps* duration)
                                :start-value start-value
                                :end-value end-value)))

(defun param-exponential-ramp (param &key time duration start-value end-value)
  (push-event (param-event-manager param)
              (make-exponential-ramp :time time
                                     :duration (max *eps* duration)
                                     :start-value start-value
                                     :end-value end-value)))

(defun param-set-target (param &key time start-value target-value time-constant)
  (setf time-constant (max 1d-8 time-constant))
  (push-event (param-event-manager param)
              (make-set-target :time time
                               :duration (max *eps* (* time-constant 20)) ; tekitou
                               :start-value start-value
                               :target-value target-value
                               :time-constant time-constant)))

(defun param-get-value (param time)
  (let ((value (param-value param)))
    (map-queue (lambda (event)
                 (cond
                   ((< (event-end-time event) time)
                    (setf value (param-event-value event (event-end-time event))))
                   ((<= (event-time event) time)
                    (setf value (param-event-value event time)))
                   (t
                    (return-from param-get-value value))))
               (event-manager-queue (param-event-manager param)))
    value))

(defun param-cancel-and-hold (param time)
  (let ((queue (event-manager-queue (param-event-manager param))))
    (map-queue (lambda (event)
                 (cond
                   ((< (event-end-time event) time))
                   ((<= (event-time event) time)
                    (etypecase event
                      (set-value)
                      (linear-ramp
                       (setf (linear-ramp-end-value event)
                             (param-event-value event time)
                             (linear-ramp-duration event)
                             (max *eps* (- time (linear-ramp-time event)))))
                      (exponential-ramp
                       (setf (exponential-ramp-end-value event)
                             (param-event-value event time)
                             (exponential-ramp-duration event)
                             (max *eps* (- time (exponential-ramp-time event)))))
                      (set-target
                       (setf (set-target-duration event)
                             (max *eps* (- time (set-target-time event)))))))
                   (t
                    (queue-delete queue *current-queue-node*))))
               queue)))
