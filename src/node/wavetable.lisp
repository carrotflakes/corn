(defpackage corn.node.wavetable
  (:use :cl
        :corn.node
        :corn.parameters
        :corn.event-manager
        :corn.buffer)
  (:import-from :alexandria
                :with-gensyms)
  (:export :wavetable
           :make-wavetable
           :wavetable-buffer
           :wavetable-loop
           :wavetable-pitch
           :wavetable-pointer
           :create-wavetable
           :wavetable-set-point))
(in-package :corn.node.wavetable)

(defstruct (wavetable (:include node))
  buffer
  loop
  (pitch (make-input :channels 1
                     :default-sample-1 0.0))
  (event-manager (make-event-manager))
  (pointer 0d0))

(defstruct (set-point (:include event))
  (pointer 0d0))

(defun create-wavetable (&key buffer (loop nil) (pointer 0d0))
  (make-wavetable :channels (buffer-channels buffer)
                   :buffer buffer
                   :loop loop
                   :pointer pointer))

(defmethod node-parts ((wavetable wavetable))
  (with-slots (loop) wavetable
    (with-input-parts
        (bindings
         initialize
         update
         pitch-sample-1
         pitch-sample-2
         finalize)
      (wavetable-pitch wavetable)
      (with-gensyms (buffer buffer-size pointer events)
        (setf bindings
              (append bindings
                      `((,events (let ((event-manager (wavetable-event-manager ,wavetable)))
                                   (update event-manager *current-time* *next-time*)
                                   (event-manager-current-events event-manager)))))
              update
              (append update
                      `((when (and ,events (<= (event-time (first ,events)) *current-time*))
                          (setf ,pointer (set-point-pointer (first ,events)))
                          (pop ,events)))))
        (case (io-channels wavetable)
          (1 (with-gensyms (sample-1)
               `(:bindings (,@bindings
                            (,buffer (wavetable-buffer ,wavetable))
                            (,buffer-size (buffer-frames ,buffer))
                            (,pointer (wavetable-pointer ,wavetable))
                            (,sample-1))
                 :initialize ,initialize
                 :update (,@update
                          (multiple-value-setq (,sample-1)
                            (interpolate ,buffer ,pointer
                                         :linear ,(if loop :loop :constant)))
                          ,(if loop
                               `(setf ,pointer (mod (+ ,pointer ,pitch-sample-1) ,buffer-size))
                               `(if (< ,pointer (+ ,buffer-size 1))
                                    (incf ,pointer ,pitch-sample-1))))
                 :sample-1 ,sample-1
                 :finalize (,@finalize
                            (setf (wavetable-pointer ,wavetable) ,pointer)))))
          (2 (with-gensyms (sample-1 sample-2)
               `(:bindings (,@bindings
                            (,buffer (wavetable-buffer ,wavetable))
                            (,buffer-size (buffer-frames ,buffer))
                            (,pointer (wavetable-pointer ,wavetable))
                            (,sample-1)
                            (,sample-2))
                 :initialize ,initialize
                 :update (,@update
                          (multiple-value-setq (,sample-1 ,sample-2)
                            (interpolate ,buffer ,pointer
                                         :linear ,(if loop :loop :constant)))
                          ,(if loop
                               `(setf ,pointer (mod (+ ,pointer ,pitch-sample-1) ,buffer-size))
                               `(if (< ,pointer (+ ,buffer-size 1))
                                    (incf ,pointer ,pitch-sample-1))))
                 :sample-1 ,sample-1
                 :sample-2 ,sample-2
                 :finalize (,@finalize
                            (setf (wavetable-pointer ,wavetable) ,pointer))))))))))

(defun wavetable-set-point (wavetable &key time pointer)
  (push-event (wavetable-event-manager wavetable)
              (make-set-point :time time
                              :duration 0.0
                              :pointer pointer)))
