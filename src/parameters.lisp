(defpackage corn.parameters
  (:use :cl)
  (:export :+sample-type+
           :+sample-format+
           :*channels*
           :*sampling-rate*
           :*buffer-size*
           :*current-time*
           :*next-time*))
(in-package :corn.parameters)

(defconstant +sample-type+ 'single-float)
(defconstant +sample-format+ :float) ; highest precision format portaudio supports is float.
(defvar *channels* 2)
(defvar *sampling-rate* 44100)
(defvar *buffer-size* 1024)

(defparameter *current-time* 0)
(defparameter *next-time* 0)
