(ql:quickload :corn)

(use-package :corn)

(defun notenum-frequency (notenum)
  (float (* 440 (expt 2 (/ (- notenum 69) 12)))))

(defvar sine-1 (corn.node.sine:make-sine :channels 2
                                         :frequency (notenum-frequency 60)))
(defvar sine-2 (corn.node.sine:make-sine :channels 2
                                         :frequency (notenum-frequency 64)))
(defvar gain (corn.node.gain:make-gain :channels 2))
(defvar gain-param (corn.node.param:make-param :value 0.5))

(connect sine-1 (corn.node.gain:gain-input gain))
(connect sine-2 (corn.node.gain:gain-input gain))
(connect gain-param (corn.node.gain:gain-gain gain))
(connect gain *master*)

(let ((*print-circle* t))
  (print (corn.node::render-body 'buffer *master*)))

(setf corn.render::*render* (corn.node:build-render *master*))

(start)

(sleep 10)

(setf (corn.node.sine::sine-frequency sine-1) (notenum-frequency 67))

(sleep 10)

(setf (corn.node.sine::sine-frequency sine-1) (notenum-frequency 60))

(loop
  with time = (current-time)
  repeat 5
  do (corn.node.param:param-set-value gain-param
                                      :time (incf time 1)
                                      :value 0.01)
     (corn.node.param:param-set-value gain-param
                                      :time (incf time 1)
                                      :value 0.5))

(stop)
