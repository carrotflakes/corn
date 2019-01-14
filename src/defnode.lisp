(defpackage corn.defnode
  (:use :cl
        :corn.node
        :corn.node.render
        :corn.buffer
        :corn.parameters)
  (:import-from :corn.render
                :make-destination)
  (:export :defnode
           :end-defnode))
(in-package :corn.defnode)

(defmacro defnode (name (&key params externals output channels) &body body)
  (let* ((package (symbol-package name))
         (create-node (intern (format nil "CREATE-~a" name) package))
         (make-node (intern (format nil "MAKE-~a" name) package)))
    `(progn
       (defstruct (,name (:include render))
         ,@externals)

       (defun ,create-node
           ,params
         (macrolet ((end-defnode ()
                      (list 'return-from ',create-node
                            (list ',make-node
                                  :channels ,channels
                                  :render '(build-render ,output)
                                  :buffer '(make-buffer *buffer-size* ,channels)
                                  ,@(loop
                                      for external in externals
                                      collect (intern (symbol-name external) :keyword)
                                      collect (list 'quote external))))))
           (let ((,output (make-destination)))
             ,@body)
           (error "(end-defnode) is required in defnode"))))))
