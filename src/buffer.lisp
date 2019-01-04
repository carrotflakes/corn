(defpackage corn.buffer
  (:use :cl
        :corn.parameters)
  (:export :make-buffer
           :buffer-frames
           :buffer-channels
           :clear))
(in-package :corn.buffer)

; いらない
;; '(defstruct buffer
;;   array
;;   frames
;;   (channels 1))

(defun make-buffer (frames channels)
  (make-array (list channels frames) :element-type +sample-type+))

(defun buffer-frames (buffer)
  (array-dimension buffer 0))

(defun buffer-channels (buffer)
  (array-dimension buffer 1))

(defun clear (buffer)
  ;(declare (optimize (speed 3) (safety 2))
  ;         (type (simple-array (or single-float double-float) (* *)) buffer))
  (dotimes (i (array-dimension buffer 0))
    (dotimes (j (array-dimension buffer 1))
      (setf (aref buffer i j) 0.0))))

(defstruct buffer-pool
  (buffers '()))
  ; use generic pool?
