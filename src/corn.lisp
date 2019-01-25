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
           :connect
           :disconnect
           :make-destination
           :set-render
           :build-render
           :render-to-buffer))
(in-package :corn)

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
