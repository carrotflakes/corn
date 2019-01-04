(defpackage corn.buffer
  (:use :cl
        :corn.parameters)
  (:export :make-buffer
           :buffer-frames
           :buffer-channels))
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

(defstruct buffer-pool
  (buffers '()))
  ; use generic pool?
