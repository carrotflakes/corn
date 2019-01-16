(defpackage corn.event-manager
  (:use :cl
        :queues
        :corn.event)
  (:export :make-event-manager
           :event-manager-current-events
           :push-event
           :update
           :event
           :event-time
           :event-duration
           :event-end-time))
(in-package :corn.event-manager)

(defun event< (x y)
  (< (event-time x) (event-time y)))

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
