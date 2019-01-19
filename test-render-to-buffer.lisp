(ql:quickload :corn)

(use-package '(:corn
               :corn.defnode
               :corn.node.sine
               :corn.node.param
               :corn.node.gain
               :corn.node.wavetable
               :corn.util))

(start)

(defun make-wave (&optional (size 44100))
  (let ((sine (make-sine :channels 2))
        (frequency-param (make-param :value 440))
        (sine-2 (make-sine :channels 1))
        (frequency-param-2 (make-param :value 222))
        (gain (create-gain :channels 1))
        (gain-param (make-param :value 100))
        (master (make-destination)))
    (connect frequency-param (sine-frequency sine))
    (connect frequency-param-2 (sine-frequency sine-2))
    (connect gain-param (gain-gain gain))
    (connect sine-2 (gain-input gain))
    (connect gain (sine-frequency sine))
    (connect sine master)
    (param-set-target gain-param :time 0 :start-value 1000 :target-value 0 :time-constant 0.1)
    (render-to-buffer (build-render master) :frames size)))

(let ((master (make-destination))
      (wavetable (create-wavetable :buffer (make-wave 44100)
                                   :loop nil
                                   :pointer 0))
      (pitch-param (make-param :value 1)))
  (connect pitch-param (wavetable-pitch wavetable))
  (connect wavetable master)
  (set-render (build-render master))
  (let ((time (current-time)))
    (loop
      for i from 1 below 10
      do (wavetable-set-point wavetable :time (incf time (* i 0.05)) :pointer 0))
    (loop
      for i from 1 below 10
      do (wavetable-set-point wavetable :time (incf time 1) :pointer (* i 4000)))))

(stop)
