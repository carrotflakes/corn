(defpackage corn.node.delay
  (:use :cl
        :corn.node
        :corn.node.param
        :corn.buffer
        :corn.parameters)
  (:import-from :alexandria
                :with-gensyms)
  (:export :make-delay
           :create-delay
           :delay-input
           :delay-delay
           :delay-max-delay))
(in-package :corn.node.delay)

(defstruct (delay (:include node))
  input
  (delay (make-input :channels 1
                     :default-sample-1 0.0))
  max-delay
  buffer
  (pointer 0))

(defun create-delay (&key channels (max-delay 4.0))
  (make-delay :channels channels
              :input (make-input :channels channels
                                 :default-sample-1 0.0
                                 :default-sample-2 0.0)
              :max-delay max-delay
              :buffer (make-buffer (ceiling (* max-delay *sampling-rate*)) channels)))

(defmethod node-parts ((delay delay))
  (with-input-parts
      (input-bindings
       input-initialize
       input-update
       input-sample-1
       input-sample-2
       input-finalize)
      (delay-input delay)
    (with-input-parts
        (delay-bindings
         delay-initialize
         delay-update
         delay-sample-1
         delay-sample-2
         delay-finalize)
        (delay-delay delay)
      (ecase (delay-channels delay)
        (2
         (with-gensyms (sample-1 sample-2 buffer pointer buffer-frames)
           `(:bindings (,@input-bindings
                        ,@delay-bindings
                        (,pointer (delay-pointer ,delay))
                        (,buffer (delay-buffer ,delay))
                        (,buffer-frames (buffer-frames ,buffer))
                        (,sample-1)
                        (,sample-2))
             :initialize (,@input-initialize ,@delay-initialize)
             :update (,@input-update
                      ,@delay-update
                      (setf (aref ,buffer 0 ,pointer) ,input-sample-1
                            (aref ,buffer 1 ,pointer) ,input-sample-2)
                      (multiple-value-setq (,sample-1 ,sample-2)
                        (interpolate ,buffer (- ,pointer (* ,delay-sample-1 *sampling-rate*))
                                     :linear :loop))
                      (setf ,pointer (mod (1+ ,pointer) ,buffer-frames)))
             :sample-1 ,sample-1
             :sample-2 ,sample-2
             :finalize (,@input-finalize
                        ,@delay-finalize
                        (setf (delay-pointer ,delay) ,pointer)))))))))
