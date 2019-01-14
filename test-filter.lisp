(ql:quickload :corn)

(use-package '(:corn
               :corn.node.sine
               :corn.node.sawtooth
               :corn.node.gain
               :corn.node.param
               :corn.node.biquad-filter
               :corn.util))

(start)

(defun f (type frequency gain q)
  (let ((sawtooth (make-sawtooth :channels 2))
        (frequency-param (make-param :value (notenum-frequency 60)))
        (filter (create-biquad-filter :channels 2
                                      :type type))
        (filter-frequency-param (make-param :value frequency))
        (filter-gain-param (make-param :value gain))
        (filter-q-param (make-param :value q))
        (gain (create-gain :channels 2))
        (gain-param (make-param :value 0.2))
        (master (make-destination)))

  (connect filter-frequency-param (biquad-filter-frequency filter))
  (connect filter-gain-param (biquad-filter-gain filter))
  (connect filter-q-param (biquad-filter-q filter))

  (connect frequency-param (sawtooth-frequency sawtooth))
  (connect sawtooth (biquad-filter-input filter))
  (connect filter (gain-input gain))
  (connect gain-param (gain-gain gain))
  (connect gain master)

  '(let ((*print-circle* t))
    (print (corn.node::render-body 'buffer master)))

    (set-render (build-render master))


  (let ((time (current-time)))
    (dolist (notenum '(60 62 64 65 67 69 71 72))
      (param-set-value frequency-param
                       :time (incf time 0.5)
                       :value (notenum-frequency notenum))))
  ))

(f :low-pass 440 10 4)
(f :high-pass 1000 10 4)
(f :all-pass 440 10 4)
(f :low-shelf 440 10 4)
(f :high-shelf 1000 10 4)
(f :peaking 440 10 4)
(f :notch 440 10 4)

(stop)
