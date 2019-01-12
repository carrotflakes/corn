(defpackage corn.event
  (:use :cl
        :queues)
  (:export :event
           :event-time
           :event-duration
           :make-event-manager
           :event-manager-current-events
           :push-event
           :update))
(in-package :corn.event)

(defstruct event
  time
  (duration 0.0))

(defun event< (x y)
  (< (event-time x) (event-time y)))

(defun event-end-time (event)
  (+ (event-time event) (event-duration event)))


(defstruct event-manager
  (current-events '())
  (queue (make-queue :priority-cqueue :compare #'event<)))

(defun push-event (event-manager event)
  (qpush (event-manager-queue event-manager) event))

(defun update (event-manager start-time end-time)
  (let ((current-events (event-manager-current-events event-manager)))
    ; remove old events
    (setf current-events
          (remove-if (lambda (event)
                       (< (event-end-time event) start-time)) ; <?
                     current-events))
    ; current events
    (setf current-events
          (append current-events
                  (loop
                    with queue = (event-manager-queue event-manager)
                    for event = (qtop queue)
                    while (and event (< (event-time event) end-time))
                    collect (qpop queue))))
    (setf (event-manager-current-events event-manager)
          current-events)))
