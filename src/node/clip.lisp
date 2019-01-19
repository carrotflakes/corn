(defpackage corn.node.clip
  (:use :cl
        :corn.node
        :corn.parameters)
  (:import-from :alexandria
                :with-gensyms)
  (:import-from :corn.util
                :clamp)
  (:export :clip
           :make-clip
           :create-clip
           :clip-input
           :clip-gain))
(in-package :corn.node.clip)

(defstruct (clip (:include node))
  (input (make-input :channels 2
                     :default-sample-1 0.0
                     :default-sample-2 0.0))
  gain)

(defun create-clip (&key channels (gain 1.0))
  (make-clip :channels channels
             :input (make-input :channels channels
                                :default-sample-1 0.0
                                :default-sample-2 0.0)
             :gain gain))

(defmethod node-parts ((clip clip))
  (with-input-parts
      (bindings
       initialize
       update
       input-sample-1
       input-sample-2
       finalize)
    (clip-input clip)
    (with-gensyms (gain sample-1 sample-2)
      (ecase (io-channels clip)
        (1 (setf bindings
                 (append bindings
                         `((,gain (clip-gain ,clip))
                           (,sample-1)))
                 update
                 (append update
                         `((setf ,sample-1 (clamp ,input-sample-1 (- ,gain) ,gain))))))
        (2 (setf bindings
                 (append bindings
                         `((,gain (clip-gain ,clip))
                           (,sample-1)
                           (,sample-2)))
                 update
                 (append update
                         `((setf ,sample-1 (clamp ,input-sample-1 (- ,gain) ,gain)
                                 ,sample-2 (clamp ,input-sample-2 (- ,gain) ,gain)))))))
      `(:bindings ,bindings
        :initialize ,initialize
        :update ,update
        :sample-1 ,sample-1
        :sample-2 ,sample-2
        :finalize ,finalize))))
