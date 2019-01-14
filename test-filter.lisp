(ql:quickload :corn)

(use-package '(:corn
               :corn.node.sine
               :corn.node.sawtooth
               :corn.node.gain
               :corn.node.param
               :corn.node.delay
               :corn.util))

(start)

(let ((sawtooth (make-sawtooth :channels 2))
      (frequency-param (make-param :value (notenum-frequency 60)))
      (delay (create-delay :channels 2))
      (delay-param (make-param :value 0.1))
      (gain (create-gain :channels 2))
      (gain-param (make-param :value 0.2)))
  (setf *master* (corn.node:make-input :channels 2
                                       :default-sample-1 0.0
                                       :default-sample-2 0.0))

  (connect frequency-param (sawtooth-frequency sawtooth))
  (connect sawtooth (gain-input gain))
  (connect gain-param (gain-gain gain))
  (connect gain *master*)

  (connect sawtooth (delay-input delay))
  (connect delay-param (delay-delay delay))
  (connect delay (gain-input gain))

  '(let ((*print-circle* t))
    (print (corn.node::render-body 'buffer *master*)))

  (setf corn.render::*render* (corn.node:build-render *master*))


  (let ((time (current-time)))
    (dolist (notenum '(60 62 64 65 67 69 71 72))
      (param-set-value frequency-param
                       :time (incf time 0.5)
                       :value (notenum-frequency notenum))))
  )

(stop)
