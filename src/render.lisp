(defpackage corn.render
  (:use :cl
        :corn.parameters
        :corn.node
        :corn.buffer)
  (:export :make-destination
           :set-render
           :initialize
           :render
           :render-to-buffer))
(in-package :corn.render)

(defun make-destination ()
  (make-input :channels  *channels*))

(defvar *render* nil)

(defvar buffer (make-buffer *buffer-size* *channels*))

(defun initialize ()
  (set-render (build-render (make-destination)))
  (setf buffer (make-buffer *buffer-size* *channels*)))

(defun set-render (render)
  (setf *render* render))

(defun render ()
  (setf *next-time* (+ *current-time* (/ *buffer-size* *sampling-rate*)))
  (when *render*
    (funcall *render* buffer))
  (setf *current-time* *next-time*)
  buffer)

(defun render-to-buffer (render &key buffer frames seconds)
  (cond
    (buffer
     (setf frames (buffer-frames buffer)))
    (frames
     (setf buffer (make-buffer frames 2)))
    (seconds
     (setf frames (ceiling (* seconds *sampling-rate*))
           buffer (make-buffer frames 2))))
  (let ((*current-time* 0)
        (*next-time* (/ frames *sampling-rate*))
        (*buffer-size* frames))
    (funcall render buffer))
  buffer)
