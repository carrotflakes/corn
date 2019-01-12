(defpackage corn.render
  (:use :cl
        :corn.parameters
        :corn.node
        :corn.event
        :corn.buffer)
  (:export :render
           :*master*
           :*current-time*
           :*event-queue*))
(in-package :corn.render)

(defvar *current-time* 0)
(defvar *event-queue* (make-event-queue))
(defvar *all-nodes* nil)
(defvar *buffers* (make-array 10 :adjustable t :fill-pointer 0))
(defvar *master* (make-input :channels 2
                             :default-sample-1 0.0
                             :default-sample-2 0.0))
(defvar *render* nil)

(defvar buffer (make-buffer *buffer-size* *channels*))

(defun initialize ())

(defun render ()
  (let* ((next-time (+ *current-time* (/ *buffer-size* *sampling-rate*)))
         (events (pop-events *event-queue* next-time)))
  ; plan
  ;; (when (or (null *all-nodes*) (nodes-corrupted *all-nodes*))
  ;;   (setf *all-nodes* (collect (list *master*)))
  ;;   (nodes-decorrupt *all-nodes*))
  ; ensure buffers

  ;(clear buffer)
  ;(corn.node.audio-node:render *master* '() buffer)

  (funcall *render* buffer)

  (setf *current-time* next-time)
  ; render nodes in order
  buffer))
