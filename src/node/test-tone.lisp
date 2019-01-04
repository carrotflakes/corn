(defpackage corn.node.test-tone
  (:use :cl
        :corn.parameters
        :corn.node.audio-node)
  (:export :test-tone
           :create-test-tone))
(in-package :corn.node.test-tone)

(defstruct (test-tone (:include audio-node))
  frequency
  phase)

(defun create-test-tone ()
  (make-test-tone :frequecy 440.0 :phase 0.0))

(defmethod render ((test-tone test-tone) input-buffer output-buffer)
  (let ((phase (test-tone-phase test-tone)))
    (loop
      with step = (coerce (* (/ (test-tone-frequency test-tone) *sampling-rate*) pi 2)
                          'single-float)
      for i below *buffer-size*
      do (incf (aref output-buffer 0 i) (* 0.5 (sin ph)))
         (incf (aref output-buffer 1 i) (* 0.5 (sin ph)))
         (incf phase step))
    (setf (test-tone-phase test-tone phase))))
