(defpackage corn.node.gain
  (:use :cl
        :corn.node
        :corn.node.param
        :corn.parameters)
  (:import-from :alexandria
                :with-gensyms)
  (:export :make-gain
           :create-gain
           :gain-input
           :gain-gain))
(in-package :corn.node.gain)

(defstruct (gain (:include node))
  (input (make-input :channels 2
                     :default-sample-1 0.0
                     :default-sample-2 0.0))
  (gain (make-input :channels 1
                    :default-sample-1 0.0)))

(defun create-gain (&key channels)
  (make-gain :channels channels
             :input (make-input :channels channels
                                :default-sample-1 0.0
                                :default-sample-2 0.0)))

(defmethod node-parts ((gain gain))
  (with-input-parts
      (input-bindings
       input-initialize
       input-update
       input-sample-1
       input-sample-2
       input-finalize)
      (gain-input gain)
    (with-input-parts
        (gain-bindings
         gain-initialize
         gain-update
         gain-sample-1
         gain-sample-2
         gain-finalize)
        (gain-gain gain)
      `(:bindings (,@input-bindings ,@gain-bindings)
        :initialize (,@input-initialize ,@gain-initialize)
        :update (,@input-update ,@gain-update)
        :sample-1 (* ,input-sample-1 ,gain-sample-1)
        :sample-2 (* ,input-sample-2 ,gain-sample-1)
        :finalize (,@input-finalize ,@gain-finalize)))))
