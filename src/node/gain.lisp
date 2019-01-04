(defpackage corn.node.gain
  (:use :cl
        :corn.node.audio-node
        :corn.node.param))
(in-package :corn.node.gain)

(defstruct (gain (:include general-node))
  gain)

(defun create-gain (&optional (gain-param (create-param)))
  (make-gain :gain gain-param))

(defmethod 
