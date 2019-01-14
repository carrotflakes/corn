(ql:quickload :corn)

(use-package '(:corn
               :corn.defnode
               :corn.node.sine
               :corn.node.param
               :corn.node.gain))

(defnode oscillator
    (:params (&optional (frequency 440))
     :externals (sine-frequency-param)
     :output output
     :channels 2)
  (let ((sine (make-sine :channels 2))
        (sine-frequency-param (make-param :value frequency)))
    (connect sine-frequency-param (sine-frequency sine))
    (connect sine output)
    (end-defnode)))

(start)

(let ((gain (create-gain :channels 2))
      (gain-param (make-param :value 0.2))
      (master (make-destination)))
  (connect gain-param (gain-gain gain))
  (connect (create-oscillator (notenum-frequency 60)) (gain-input gain))
  (connect (create-oscillator (notenum-frequency 64)) (gain-input gain))
  (connect (create-oscillator (notenum-frequency 67)) (gain-input gain))
  (connect (create-oscillator (notenum-frequency 71)) (gain-input gain))
  (connect gain master)
  (set-render (build-render master)))
