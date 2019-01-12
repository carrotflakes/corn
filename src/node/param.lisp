(defpackage corn.node.param
  (:use :cl
        :corn.parameters
        :corn.node
        :corn.event)
  (:import-from :alexandria
                :with-gensyms)
  (:export :make-param
           :param-value
           :param-set-value))
(in-package :corn.node.param)

(defstruct (param (:include node (channels 1)))
  (value 0.0)
  (event-manager (make-event-manager)))

(defstruct (set-value (:include event))
  (value 0.0))

(defmethod node-parts ((param param))
  (with-gensyms (events value)
    `(:bindings ((,events (progn
                            (update (param-event-manager ,param) *current-time* *next-time*)
                            (event-manager-current-events (param-event-manager ,param))))
                 (,value (param-value ,param)))
      :initialize ()
      :update ((when (and ,events (<= (event-time (first ,events)) *current-time*))
                 (let ((event (pop ,events)))
                   (etypecase event
                     (set-value
                      (setf ,value (set-value-value event)))))))
      :sample-1 ,value
      ;:sample-2 ,value
      :finalize ((setf (param-value ,param) ,value)))))

(defun param-set-value (param &key time value)
  (push-event (param-event-manager param)
              (make-set-value :time time
                              :duration 0.0
                              :value value)))
