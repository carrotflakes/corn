(defpackage corn.node.param
  (:use :cl
        :corn.parameters
        :corn.node
        :corn.event)
  (:import-from :alexandria
                :with-gensyms)
  (:export :make-param
           :param-set-value))
(in-package :corn.node.param)

(defstruct (param (:include node (channels 1)))
  (value 0.0)
  (event-manager (make-event-manager)))

(defstruct (set-value (:include event))
  (value 0.0))

(defmethod node-parts ((param param))
  (with-gensyms (events)
    `(:bindings ((,events (progn
                            (update event-manager *current-time* *next-time*)
                            (event-manager-current-events (param-event-manager ,param)))))
      :initialize ()
      :update ()
      :sample-1 ,0
      :sample-2 ,0
      :finalize ())))

(defun param-set-value (param &key time value)
  (push-event (param-event-manager param)
              (make-set-value :time time
                              :value value)))
