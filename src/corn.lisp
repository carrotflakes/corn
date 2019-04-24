(defpackage corn
  (:use :cl
        :corn.parameters
        :corn.buffer
        :corn.render)
  (:export :connect
           :disconnect
           :make-destination
           :make-render))
(in-package :corn)
