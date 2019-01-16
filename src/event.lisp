(defpackage corn.event
  (:use :cl)
  (:export :event
           :event-time
           :event-duration
           :event-end-time))
(in-package :corn.event)

(defstruct event
  time
  (duration 0.0))

(defun event-end-time (event)
  (+ (event-time event) (event-duration event)))
