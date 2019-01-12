(defpackage corn.node.nop
  (:use :cl
        :corn.node)
  (:import-from :alexandria
                :with-gensyms)
  (:export :make-nop))
(in-package :corn.node.nop)

(defstruct (nop (:include node))
  (input (make-input :default-sample-1 0.0 :default-sample-2 0.0
                     :channels 2)))

(defmethod node-parts ((nop nop))
  (with-input-parts (bindings initialize update sample-1 sample-2 finalize) (nop-input nop)
    `(:bindings ,bindings
      :initialize ,initialize
      :update ,update
      :sample-1 ,sample-1
      :sample-2 ,sample-2
      :finalize ,finalize)))
