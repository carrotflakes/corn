(ql:quickload :corn)

(use-package '(:corn
               :corn.defnode
               :corn.node.sawtooth
               :corn.node.param
               :corn.node.gain
               :corn.util))

(start)

(let ((master (make-destination))
      (sawtooth (make-sawtooth :channels 2))
      (sawtooth-frequency-param (make-param :value 440)))
  (connect sawtooth-frequency-param (sawtooth-frequency sawtooth))
  (connect sawtooth master)
  (set-render (build-render master))

  (let ((time (current-time)))
    (param-set-value sawtooth-frequency-param
                     :time (incf time)
                     :value 880)
    (param-linear-ramp sawtooth-frequency-param
                       :time (incf time)
                       :duration 2
                       :start-value 440
                       :end-value 40)
    (param-exponential-ramp sawtooth-frequency-param
                            :time (incf time 2)
                            :duration 2
                            :start-value 440
                            :end-value 40)
    (param-set-target sawtooth-frequency-param
                      :time (incf time 2)
                      :start-value 880
                      :target-value 440
                      :time-constant 0.01)
    (param-set-target sawtooth-frequency-param
                      :time (incf time)
                      :start-value 880
                      :target-value 440
                      :time-constant 0.1)
    (param-set-target sawtooth-frequency-param
                      :time (incf time)
                      :start-value 880
                      :target-value 440
                      :time-constant 1)))

(stop)
