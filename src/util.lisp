(defpackage corn.util
  (:use :cl)
  (:export :notenum-frequency
           :clamp
           :interpolate-exponential-ramp))
(in-package :corn.util)

(defun notenum-frequency (notenum)
  (float (* 440 (expt 2 (/ (- notenum 69) 12)))))

(defun clamp (value min max)
  (cond
    ((< value min) min)
    ((< max value) max)
    (t value)))

(defun interpolate-exponential-ramp (y-1 y-2 x)
  (exp (+ (* (log y-1) (- 1 x)) (* (log y-2) x))))
