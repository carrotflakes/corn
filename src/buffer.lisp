(defpackage corn.buffer
  (:use :cl
        :corn.parameters)
  (:export :make-buffer
           :buffer-frames
           :buffer-channels
           :clear
           :interpolate))
(in-package :corn.buffer)

(defun make-buffer (frames channels)
  (make-array (list channels frames) :element-type +sample-type+))

(defun buffer-frames (buffer)
  (array-dimension buffer 1))

(defun buffer-channels (buffer)
  (array-dimension buffer 0))

(defun clear (buffer)
  ;(declare (optimize (speed 3) (safety 2))
  ;         (type (simple-array (or single-float double-float) (* *)) buffer))
  (dotimes (i (array-dimension buffer 0))
    (dotimes (j (array-dimension buffer 1))
      (setf (aref buffer i j) 0.0))))

(defun interpolate (buffer pointer method mode &key (constant 0.0))
  ;(declare (optimize (speed 3) (safety 2))
  ;         (type (simple-array (or single-float double-float) (* *)) buffer))
  (let ((frames (buffer-frames buffer)))
    (ecase (buffer-channels buffer)
      (1 (flet ((get-frame (pointer)
                  (cond
                    ((< pointer 0)
                     (ecase mode
                       (:constant constant)
                       (:loop (aref buffer 0 (mod pointer frames)))
                       (:extend (aref buffer 0 0))))
                    ((<= frames pointer)
                     (ecase mode
                       (:constant constant)
                       (:loop (aref buffer 0 (mod pointer frames)))
                       (:extend (aref buffer 0 (1- frames)))))
                    (t
                     (aref buffer 0 pointer)))))
           (ecase method
             (:nearest-neighbor
              (values (get-frame (round pointer))))
             (:linear
              (multiple-value-bind (pointer rate) (floor pointer)
                (values (+ (* (get-frame pointer) (- 1 rate))
                           (* (get-frame (1+ pointer)) rate))))))))
      (2 (flet ((get-frame (pointer)
                  (cond
                    ((< pointer 0)
                     (ecase mode
                       (:constant (values constant constant))
                       (:loop (values (aref buffer 0 (mod pointer frames))
                                      (aref buffer 1 (mod pointer frames))))
                       (:extend (values (aref buffer 0 0)
                                        (aref buffer 1 0)))))
                    ((<= frames pointer)
                     (ecase mode
                       (:constant (values constant constant))
                       (:loop (values (aref buffer 0 (mod pointer frames))
                                      (aref buffer 1 (mod pointer frames))))
                       (:extend (values (aref buffer 0 (1- frames))
                                        (aref buffer 1 (1- frames))))))
                    (t
                     (values (aref buffer 0 pointer)
                             (aref buffer 1 pointer))))))
           (ecase method
             (:nearest-neighbor
              (get-frame (round pointer)))
             (:linear
              (multiple-value-bind (pointer rate) (floor pointer)
                (multiple-value-bind (l1 r1) (get-frame pointer)
                  (multiple-value-bind (l2 r2) (get-frame (1+ pointer))
                    (values (+ (* l1 (- 1 rate))
                               (* l2 rate))
                            (+ (* r1 (- 1 rate))
                               (* r2 rate)))))))))))))