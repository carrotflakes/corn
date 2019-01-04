(defpackage corn.general-node
  (:use :cl)
  (:export :general-node
           :inputs
           :outputs
           :corrupted
           :general-node-inputs
           :general-node-outputs
           :general-node-corrupted
           :connect
           :disconnect
           :do-general-node
           :collect
           :nodes-corrupted
           :nodes-decorrupt))
(in-package :corn.general-node)

(defstruct general-node
  (inputs '())
  (outputs '())
  (corrupted t))

(defmethod connect ((src-node general-node) (dst-node general-node))
  (setf (general-node-corrupted dst-node) t)
  (pushnew dst-node (general-node-outputs src-node))
  (pushnew src-node (general-node-inputs dst-node)))

(defun disconnect (src-node dst-node)
  (setf (general-node-corrupted dst-node) t)
  (setf (general-node-outputs src-node)
        (remove dst-node (general-node-outputs src-node))
        (general-node-inputs dst-node)
        (remove src-node (general-node-inputs dst-node))))

(defmacro do-general-node ((node nodes &optional (visited (gensym "VISITED"))) &body body)
  `(loop
     with nodes% = ,nodes
     with ,visited = '()
     while nodes%
     for ,node = (pop nodes%)
     unless (member ,node ,visited)
     do (progn ,@body)
        (setf nodes% (append (general-node-inputs node) nodes%))
        (push ,node ,visited)))

(defun collect (nodes)
  (let ((visited '()))
    (do-general-node (node nodes visited))
    visited))

(defun nodes-corrupted (nodes)
  (dolist (node nodes)
    (when (general-node-corrupted node)
      (return-from corrupted t))))

(defun nodes-decorrupt (nodes)
  (dolist (node nodes)
    (setf (general-node-corrupted node) nil)))

; detect-cycle
