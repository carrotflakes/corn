(defpackage corn.render
  (:use :cl
        :corn.parameters
        :corn.node
        :corn.buffer)
  (:export :make-destination
           :set-render
           :render))
(in-package :corn.render)

(defun make-destination ()
  (make-input :channels 2))

(defvar *render* nil)

(defvar buffer (make-buffer *buffer-size* *channels*))

(defun initialize ())

(defun set-render (render)
  (setf *render* render))

(defun render ()
  (setf *next-time* (+ *current-time* (/ *buffer-size* *sampling-rate*)))
  (when *render*
    (funcall *render* buffer))
  (setf *current-time* *next-time*)
  buffer)
