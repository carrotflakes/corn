(defpackage corn.render
  (:use :cl
        :corn.parameters
;        :corn.general-node
        :corn.buffer)
  (:export :render
           :*master*))
(in-package :corn.render)

(defvar *all-nodes* nil)
(defvar *buffers* (make-array 10 :adjustable t :fill-pointer 0))
;(defvar *master* (make-mixer))
(defvar *plan* '())

(defvar buffer (make-buffer +frames-per-buffer+ +channels+))
(defvar ph 0.0)

(defun render ()
  ; plan
  ;; (when (or (null *all-nodes*) (nodes-corrupted *all-nodes*))
  ;;   (setf *all-nodes* (collect (list *master*)))
  ;;   (nodes-decorrupt *all-nodes*))
  ; ensure buffers
  (loop
    with scale = (coerce (* (/ 440.0 *sampling-rate*) pi 2) 'single-float)
    for i below +frames-per-buffer+
    do (setf (aref buffer 0 i) (* 0.5 (sin ph))
             (aref buffer 1 i) (* 0.5 (sin ph)))
       (incf ph scale))
  ; render nodes in order
  buffer) ; returns (simple-vector single-float (2 1024))
