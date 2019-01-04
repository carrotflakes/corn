(defpackage corn.render
  (:use :cl
        :corn.parameters
        :corn.general-node
        :corn.event
        :corn.buffer
        :corn.node.mixer)
  (:export :render
           :*master*
           :*current-time*
           :*event-queue*))
(in-package :corn.render)

(defvar *current-time* 0)
(defvar *event-queue* (make-event-queue))
(defvar *all-nodes* nil)
(defvar *buffers* (make-array 10 :adjustable t :fill-pointer 0))
(defvar *master* (create-mixer))
(defvar *plan* '())

(defvar buffer (make-buffer +frames-per-buffer+ +channels+))

(defun render ()
  ; plan
  ;; (when (or (null *all-nodes*) (nodes-corrupted *all-nodes*))
  ;;   (setf *all-nodes* (collect (list *master*)))
  ;;   (nodes-decorrupt *all-nodes*))
  ; ensure buffers
  (clear buffer)
  (corn.node.audio-node:render *master* '() buffer)
  ; render nodes in order
  buffer)
