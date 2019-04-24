(defpackage corn.portaudio
  (:use :cl
        :portaudio
        :bordeaux-threads)
  (:import-from :corn.parameters
                :*channels*
                :*sampling-rate*
                :+sample-format+
                :*buffer-size*)
  (:export :start
           :stop
           :current-time))
(in-package :corn.portaudio)

(defvar *thread* nil)
(defvar *thread-end* nil)
(defvar *current-time* nil)

(defun start (render)
  (when *thread*
    (error "corn already started"))
  (setf *thread-end* nil)
  (setf *thread*
        (make-thread
         (lambda ()
           (unwind-protect
                (with-audio
                    (with-default-audio-stream
                        (astream *channels* *channels*
                                 :sample-format +sample-format+
                                 :sample-rate (coerce *sampling-rate* 'double-float)
                                 :frames-per-buffer *buffer-size*)
                      (loop
                        with buffer = nil
                        until *thread-end*
                        do (multiple-value-setq (buffer *current-time*) (funcall render))
                           (write-stream astream
                                         (merge-channels-into-array astream
                                                                    buffer)))))
             (setf *thread* nil)))
         :name "corn")))

(defun stop ()
  (setf *thread-end* t))

(defun current-time ()
  *current-time*)
