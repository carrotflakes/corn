(defpackage corn.event
  (:use :cl
        :event
        :audio-event
        :note-event
        :make-audio-event
        :make-note-event))
(in-package :corn.event)

(defstruct event
  time
  (ended nil))

(defstruct (audio-event (:include event))
  (rate 1d0)
  duration)

(defstruct (note-event (:include event))
  notemun
  velocity
  duration)


(defstruct event-manager
  current-events
  queue)

(defun push-event (event-manager event)
  )

(defun update (event-manager time)
  )
