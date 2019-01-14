(defpackage corn.render
  (:use :cl
        :corn.parameters
        :corn.node
        :corn.buffer)
  (:export :render
           :*master*))
(in-package :corn.render)

(defparameter *master* (make-input :channels 2
                                   :default-sample-1 0.0
                                   :default-sample-2 0.0))
(defvar *render* (build-render *master*))

(defvar buffer (make-buffer *buffer-size* *channels*))

(defun initialize ())

(defun render ()
  (setf *next-time* (+ *current-time* (/ *buffer-size* *sampling-rate*)))
  (funcall *render* buffer)
  (setf *current-time* *next-time*)
  buffer)
