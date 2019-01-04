(defpackage corn.node.param
  (:use :cl
        :corn.general-node)
  (:export :param
           :create-param))
(in-package :corn.node.param)

(defstruct (param (:include general-node))
  (value 0))
  ;schedule

(defun create-param ()
  (make-param))
