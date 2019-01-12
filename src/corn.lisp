(defpackage corn
  (:use :cl
        :portaudio
        :bordeaux-threads
        :corn.parameters
        :corn.buffer
        :corn.render
        :corn.node)
  (:export :start
           :stop
           :current-time
           :put-event
           :connect
           :disconnect
           :*master*))
(in-package :corn)

#|
(defun test-read-write-converted-echo ()
  (with-audio
      (format t "~%=== Wire on. Will run ~D seconds . ===~%" +seconds+)
    (with-default-audio-stream (astream +num-channels+ +num-channels+
                                        :sample-format +sample-format+
                                        :sample-rate *sampling-rate*
                                        :frames-per-buffer +frames-per-buffer+)
      (dotimes (i (round (/ (* +seconds+ *sampling-rate*) +frames-per-buffer+)))
        (write-stream astream
                      (merge-channels-into-array astream
                                                 (separate-array-to-channels astream
                                                                             (read-stream astream))))))))

(defun create-wave (wave-type
                    &key (sampling-rate 44100)
                         (channels 1)
                         (interpolation :linear)
                         (gain 1d0))
  (let ((array (make-array (list channels sampling-rate) :element-type 'single-float)))
    (ecase wave-type
      (:square
       (loop
         with half-sampling-rate = (floor (/ sampling-rate 2))
         for i below half-sampling-rate
         do (setf (aref array i) gain
                  (aref array (+ i half-sampling-rate)) (- gain))))))
  (make-wave :array array
             :sampling-rate sampling-rate
             :interpolation interpolation))
|#


(defvar *thread* nil)
(defvar *thread-end* nil)

(defun thread ()
  (unwind-protect
       (with-audio
         (with-default-audio-stream
             (astream *channels* *channels*
                      :sample-format +sample-format+
                      :sample-rate (coerce *sampling-rate* 'double-float)
                      :frames-per-buffer *buffer-size*)
           (loop
             until *thread-end*
             do (write-stream astream
                              (merge-channels-into-array astream
                                                         (render))))))
    (setf *thread* nil)))

(defun start ()
  (when *thread*
    (error "corn already started"))
  (setf *thread-end* nil)
  (setf *thread* (make-thread #'thread :name "corn")))

(defun stop ()
  (setf *thread-end* t))

(defun current-time ()
  *current-time*)

(defun put-event (event)
  (push-event *event-queue* event))
