(defpackage corn.node.render
  (:use :cl
        :corn.node
        :corn.buffer
        :corn.parameters)
  (:import-from :alexandria
                :with-gensyms)
  (:export :render
           :make-render
           :render-render))
(in-package :corn.node.render)

(defun dummy-render (buffer)
  (declare (ignore buffer)))

(defstruct (render (:include node))
  render
  buffer)

(defun create-render (&key (channels 2) (render dummy-render))
  (make-render :channels channels
               :render render
               :buffer (make-buffer *buffer-size* channels)))

(defmethod node-parts ((render render))
  (with-gensyms (buffer)
    `(:bindings ((,buffer (render-buffer ,render)))
      :initialize ((funcall (render-render ,render) ,buffer))
      :update ()
      :sample-1 (aref ,buffer 0 *buffer-pointer*)
      :sample-2 (aref ,buffer 1 *buffer-pointer*)
      :finalize ())))
