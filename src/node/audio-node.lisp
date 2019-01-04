(defpackage corn.node.audio-node
  (:use :cl
        :corn.general-node)
  (:export :audio-node
           :render))
(in-package :corn.node.audio-node)

(defstruct (audio-node (:include general-node)))

(defgeneric render (audio-node input-buffer output-buffer))
