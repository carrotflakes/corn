(ql:quickload :corn)

(use-package '(:corn
               :corn.node.multi-oscillator
               :corn.node.gain
               :corn.util))

(start)

(let ((osc (make-multi-oscillator :channels 2 :type :sine))
      (frequency-param (make-param :value 440))
      (master (make-destination)))
  (connect frequency-param (multi-oscillator-frequency osc))
  (connect osc master)
  (set-render (build-render master))

  (sleep 1)
  (setf (multi-oscillator-type osc) :square)
  (sleep 1)
  (setf (multi-oscillator-type osc) :triangle)
  (sleep 1)
  (setf (multi-oscillator-type osc) :sawtooth)
  (sleep 1)
  (setf (multi-oscillator-type osc) :triangle)
  (loop
    with time = (current-time)
    for i below 10
    do (multi-oscillator-set-phase osc
                                   :time (incf time (* i 0.5))
                                   :phase 0)))
