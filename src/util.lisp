(defpackage corn.util
  (:use :cl)
  (:export :notenum-frequency
           :clamp))
(in-package :corn.util)

(defun notenum-frequency (notenum)
  (float (* 440 (expt 2 (/ (- notenum 69) 12)))))

(defun clamp (value min max)
  (cond
    ((< value min) min)
    ((< max value) max)
    (t value)))
