(defpackage corn.render
  (:use :cl
        :corn.parameters
        :corn.node
        :corn.buffer)
  (:export :make-destination
           :make-render))
(in-package :corn.render)

(defun make-destination ()
  (make-input :channels  *channels*))

(defun make-render (input)
  (let* ((buffer-size *buffer-size*)
         (channels *channels*)
         (render (build-render input))
         (buffer (make-buffer buffer-size channels))
         (current-time 0.0))
    (lambda ()
      (let* ((*buffer-size* buffer-size)
             (*channels* channels)
             (*current-time* current-time)
             (*next-time* (+ *current-time* (/ *buffer-size* *sampling-rate*))))
        (funcall render buffer)
        (setf current-time *next-time*))
      (values buffer current-time))))

#|
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
|#
