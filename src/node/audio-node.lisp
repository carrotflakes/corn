(defpackage corn.node.audio-node
  (:use :cl
        :corn.general-node)
  (:export))
(in-package :corn.node.audio-node)

(defstruct (audio-node (:include general-node)))

(defgeneric render ((audio-node audio-node) input-buffer output-buffer)
  (loop
    with frames = (buffer 
