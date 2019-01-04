(defpackage corn.parameters
  (:use :cl)
  (:export :+sample-type+
           :+frames-per-buffer+
           :+sample-format+
           :+channels+
           :*sampling-rate*))
(in-package :corn.parameters)

(defconstant +sample-type+ 'single-float)
(defconstant +frames-per-buffer+ 1024)
(defconstant +sample-format+ :float) ; highest precision format portaudio supports is float.
(defconstant +channels+ 2)
(defvar *sampling-rate* 44100)
