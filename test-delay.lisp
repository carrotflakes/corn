(ql:quickload :corn)

(use-package '(:corn
               :corn.node.sine
               :corn.node.gain
               :corn.node.param
               :corn.node.delay))

(defun notenum-frequency (notenum)
  (float (* 440 (expt 2 (/ (- notenum 69) 12)))))

(start)

(progn
(defparameter sine-1 (make-sine :channels 2))
(defparameter frequency-param-1 (make-param :value (notenum-frequency 60)))
(defparameter sine-2 (make-sine :channels 2))
(defparameter frequency-param-2 (make-param :value (notenum-frequency 64)))
(defparameter sine-3 (make-sine :channels 1))
(defparameter frequency-param-3 (make-param :value 2))
(defparameter delay (create-delay :channels 2))
(defparameter delay-param (make-param :value 0.2))
(defparameter gain (make-gain :channels 2))
(defparameter gain-param (make-param :value 0.5))
(defparameter gain-2 (corn.node.gain::create-gain :channels 1))
(defparameter gain-param-2 (make-param :value 0.001))

(setf *master* (corn.node:make-input :channels 2
                                     :default-sample-1 0.0
                                     :default-sample-2 0.0))

(connect frequency-param-1 (sine-frequency sine-1))
(connect sine-1 (gain-input gain))
(connect frequency-param-2 (sine-frequency sine-2))
(connect sine-2 (delay-input delay))
(connect delay (gain-input gain))
(connect delay-param (delay-delay delay))
(connect frequency-param-3 (sine-frequency sine-3))

(connect gain-param-2 (gain-gain gain-2))
(connect sine-3 (gain-input gain-2))
(connect gain-2 (delay-delay delay))

(connect gain-param (gain-gain gain))
(connect gain *master*)

'(let ((*print-circle* t))
  (print (corn.node::render-body 'buffer *master*)))

(setf corn.render::*render* (corn.node:build-render *master*))

(let ((time (current-time)))
  (dolist (notenum '(60 62 64 65 67 69 71 72))
    (param-set-value frequency-param-2
                     :time (incf time 0.5)
                     :value (notenum-frequency notenum))))
(loop
  with time = (current-time)
  repeat 5
  do (param-set-value frequency-param-1
                      :time (incf time 1)
                      :value (notenum-frequency 67))
     (param-set-value frequency-param-1
                      :time (incf time 1)
                      :value (notenum-frequency 60)))

)

(stop)
