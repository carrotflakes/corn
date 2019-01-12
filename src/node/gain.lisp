(defpackage corn.node.gain
  (:use :cl
        :corn.node
        :corn.parameters)
  (:import-from :alexandria
                :with-gensyms)
  (:export :make-gain
           :gain-input
           :gain-gain))
(in-package :corn.node.gain)

(defstruct (gain (:include node))
  (input (make-input :default-sample-1 0.0 :default-sample-2 0.0
                     :channels 2))
  (gain 1.0))

(defmethod node-parts ((gain gain))
  (with-gensyms (gain-sym)
    (with-input-parts (bindings initialize update sample-1 sample-2 finalize) (gain-input gain)
      `(:bindings ((,gain-sym (gain-gain ,gain)) ,@bindings)
        :initialize ,initialize
        :update ,update
        :sample-1 (* ,gain-sym ,sample-1)
        :sample-2 (* ,gain-sym ,sample-2)
        :finalize ,finalize))))
