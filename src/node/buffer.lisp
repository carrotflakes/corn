(defpackage corn.node.buffer
  (:use :cl
        :corn.node
        :corn.parameters)
  (:import-from :alexandria
                :with-gensyms)
  (:export :make-buffer
           :buffer-buffer))
(in-package :corn.node.buffer)

(defstruct (buffer (:include node))
  buffer)

(defmethod node-parts ((buffer buffer))
  (with-gensyms (buffer-sym)
    `(:bindings ((,buffer-sym (buffer-buffer ,buffer)))
      :initialize ()
      :update ()
      :sample-1 (aref ,buffer-sym 0 *buffer-pointer*)
      :sample-2 (aref ,buffer-sym 1 *buffer-pointer*)
      :finalize ())))
