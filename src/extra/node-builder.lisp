(defpackage corn.extra.node-builder
  (:use :cl
        :corn)
  (:export :build))
(in-package :corn.extra.node-builder)

(defun slot-value* (object key)
  (slot-value object
              (find-symbol (symbol-name key)
                           (symbol-package (type-of object)))))

(defmacro build (tree &optional (destination '(make-destination)))
  (let* ((destination-sym (gensym "DESTINATION"))
         (bindings `((,destination-sym ,destination)))
         (connections ()))
    (labels ((f (tree parent)
               (cond
                 ((symbolp tree)
                  (push (list tree parent) connections))
                 ((eq (first tree) '+)
                  (loop
                    for node in (cdr tree)
                    do (f node parent)))
                 ((listp tree)
                  (let ((node-sym (if (symbolp (first tree))
                                      (first tree)
                                      (let ((symbol (gensym "NODE")))
                                        (push `(,symbol ,(first tree)) bindings)
                                        symbol))))
                    (push (list node-sym parent) connections)
                    (pop tree)
                    (loop
                      for key = (pop tree)
                      for value = (pop tree)
                      while (and key value)
                      do (f value `(slot-value* ,node-sym ,key))))))))
      (f tree destination-sym))
    `(let
         ,bindings
       ,@(loop
           for (output input) in connections
           collect `(connect ,output ,input))
       ,destination-sym)))
