(ql:quickload :corn)

(use-package '(:corn
               :corn.node.sine
               :corn.node.gain
               :corn.node.param
               :corn.node.pan))

(defun notenum-frequency (notenum)
  (float (* 440 (expt 2 (/ (- notenum 69) 12)))))

(start)

(progn
(defparameter sine-1 (make-sine :channels 1))
(defparameter frequency-param-1 (make-param :value (notenum-frequency 60)))
(defparameter sine-4 (make-sine :channels 1))
(defparameter frequency-param-4 (make-param :value 0.2))
(defparameter gain (create-gain :channels 1))
(defparameter gain-param (make-param :value 0.2))
(defparameter pan (create-pan :channels 1))

(setf *master* (corn.node:make-input :channels 2
                                     :default-sample-1 0.0
                                     :default-sample-2 0.0))

(connect frequency-param-1 (sine-frequency sine-1))
(connect sine-1 (gain-input gain))

(connect gain-param (gain-gain gain))
(connect gain (pan-input pan))
(connect frequency-param-4 (sine-frequency sine-4))
(connect sine-4 (pan-pan pan))
(connect pan *master*)

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

(loop
  with time = (current-time)
  repeat 10
  do (param-linear-ramp gain-param
                        :time (incf time 0.5)
                        :duration 0.5
                        :start-value 0
                        :end-value 0.2))

)

(stop)
