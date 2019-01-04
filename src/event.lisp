(defpackage corn.event
  (:use :cl
        :queues)
  (:export :event
           :make-event-queue
           :push-event
           :pop-events))
(in-package :corn.event)

(defstruct event
  time)

(defun event< (x y)
  (< (event-time x) (event-time y)))


(defun make-event-queue ()
  (make-queue :priority-cqueue :compare #'event<))

(defun push-event (event-queue event)
  (qpush event-queue event))

(defun pop-events (event-queue time)
  (loop
    for event = (qtop event-queue)
    while (and event (< (event-time event) time))
    collect (qpop event-queue)))
