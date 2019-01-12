(ql:quickload :corn)

(use-package :corn)

(defun notenum-frequency (notenum)
  (float (* 440 (expt 2 (/ (- notenum 69) 12)))))

(defvar sine-1 (corn.node.sine:make-sine :channels 2
                                         :frequency (notenum-frequency 60)))
(defvar sine-2 (corn.node.sine:make-sine :channels 2
                                         :frequency (notenum-frequency 64)))
(defvar gain (corn.node.gain:make-gain :channels 2
                                       :gain 0.5))

(connect sine-1 (corn.node.gain:gain-input gain))
(connect sine-2 (corn.node.gain:gain-input gain))
(connect gain *master*)

(let ((*print-circle* t))
  (print (corn.node::render-body 'buffer *master*)))

(setf corn.render::*render* (corn.node:build-render *master*))

(start)

B(sleep 10)

(setf (corn.node.sine::sine-frequency sine-1) (notenum-frequency 67))

(sleep 10)

(setf (corn.node.sine::sine-frequency sine-1) (notenum-frequency 60))

(stop)
