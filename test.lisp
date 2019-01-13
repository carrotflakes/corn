(ql:quickload :corn)

(use-package :corn)

(defun notenum-frequency (notenum)
  (float (* 440 (expt 2 (/ (- notenum 69) 12)))))

(defparameter sine-1 (corn.node.sine:make-sine :channels 2))
(defparameter frequency-param-1 (corn.node.param:make-param :value (notenum-frequency 60)))
(defparameter sine-2 (corn.node.sine:make-sine :channels 2))
(defparameter frequency-param-2 (corn.node.param:make-param :value (notenum-frequency 64)))
(defparameter gain (corn.node.gain:make-gain :channels 2))
(defparameter gain-param (corn.node.param:make-param :value 0.5))

(setf *master* (make-input :channels 2
                           :default-sample-1 0.0
                           :default-sample-2 0.0))

(connect sine-1 (corn.node.gain:gain-input gain))
(connect frequency-param-1 (corn.node.sine:sine-frequency sine-1))
(connect sine-2 (corn.node.gain:gain-input gain))
(connect frequency-param-2 (corn.node.sine:sine-frequency sine-2))
(connect gain-param (corn.node.gain:gain-gain gain))
(connect gain *master*)

(let ((*print-circle* t))
  (print (corn.node::render-body 'buffer *master*)))

(setf corn.render::*render* (corn.node:build-render *master*))

(start)

(loop
  with time = (current-time)
  repeat 5
  do (corn.node.param:param-set-value frequency-param-1
                                      :time (incf time 1)
                                      :value (notenum-frequency 67))
     (corn.node.param:param-set-value gain-param
                                      :time time
                                      :value 0.01)
     (corn.node.param:param-set-value frequency-param-1
                                      :time (incf time 1)
                                      :value (notenum-frequency 60))
     (corn.node.param:param-set-value gain-param
                                      :time time
                                      :value 0.5))

(stop)
