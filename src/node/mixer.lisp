(defpackage corn.node.mixer
  (:use :cl
        :corn.buffer
        :corn.parameters
        :corn.node.audio-node
        ;:corn.node.param
        )
  (:export :mixer
           :create-mixer))
(in-package :corn.node.mixer)

(defstruct (mixer (:include audio-node))
  gain
  pan)

(defun create-mixer ()
  (make-mixer :gain 0.0 :pan 0.0))

(defmethod render ((mixer mixer) input-buffer output-buffer)
  (let ((gain (mixer-gain mixer)))
    (dotimes (ch *channels*)
      (loop
        for i below *buffer-size*
        do (incf (aref output-buffer ch i) (* gain (aref input-buffer ch i)))))))
