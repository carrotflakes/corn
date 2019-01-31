(ql:quickload '(:corn
                :corn-nodes
                :corn-extra-voice-manager
                :corn-extra-node-builder
                :alexandria))

(use-package '(:corn
               :corn.node.nop
               :corn.node.multi-oscillator
               :corn.node.biquad-filter
               :corn.node.param
               :corn.node.gain
               :corn.node.pan
               :corn.node.clip
               :corn.util
               :corn.extra.voice-manager
               :corn.extra.node-builder))

(defstruct (synth (:include nop))
  voice-manager)

(defun synth-noteon (synth &key time notenum)
  (voice-manager-noteon (synth-voice-manager synth) notenum time
                        :frequency (notenum-frequency notenum)))

(defun synth-noteoff (synth &key time notenum)
  (voice-manager-noteoff (synth-voice-manager synth) notenum time))


(defun make-voice-1 (output)
  (let ((multi-oscillator (make-multi-oscillator :channels 2 :type :sawtooth))
        (frequency-param (make-param :value 440))
        (filter (create-biquad-filter :type :low-pass :channels 2))
        (filter-frequency-param (make-param :value 500))
        (filter-q-param (make-param :value 1))
        (gain (create-gain :channels 2))
        (gain-param (make-param :value 0.0)))
    (build (gain
            :input (filter
                    :input (multi-oscillator
                            :frequency frequency-param)
                    :frequency filter-frequency-param
                    :q filter-q-param)
            :gain gain-param)
           output)
    (list :noteon
          (lambda (time &key frequency)
            (multi-oscillator-set-phase multi-oscillator
                                        :time time
                                        :phase 0)
            (param-cancel-and-hold gain-param time)
            (param-exponential-ramp gain-param
                                    :time time
                                    :duration 3
                                    :start-value 0.7
                                    :end-value 0.4)
            (param-cancel-and-hold frequency-param time)
            (param-set-value frequency-param
                             :time time
                             :value frequency)
            (param-cancel-and-hold filter-frequency-param time)
            (param-linear-ramp filter-frequency-param
                               :time time
                               :duration 0.5
                               :start-value 1200
                               :end-value 400))
          :noteoff
          (lambda (time)
            (param-cancel-and-hold gain-param time)
            (param-set-target gain-param
                              :time time
                              :start-value (param-get-value gain-param time)
                              :target-value 0.0
                              :time-constant 0.1)
            (param-cancel-and-hold filter-frequency-param time)))))

(defun create-synth-1 (voices-num)
  (defun noteon (voice &rest rest)
    (apply (getf voice :noteon) rest))
  (defun noteoff (voice &rest rest)
    (apply (getf voice :noteoff) rest))
  (let* ((input (corn.node:make-input :channels 2))
         (voices (loop
                   repeat voices-num
                   collect (make-voice-1 input)))
         (voice-manager (create-voice-manager :nodes voices
                                              :noteon #'noteon
                                              :noteoff #'noteoff)))
    (make-synth :channels 2
                :input input
                :voice-manager voice-manager)))

(defun make-voice-2 (output)
  (let ((osc-1 (make-multi-oscillator :channels 2 :type :sine))
        (frequency-1-param (make-param :value 440))
        (osc-2 (make-multi-oscillator :channels 1 :type :sine))
        (frequency-2-param (make-param :value 440))
        (gain-1 (create-gain :channels 2))
        (gain-1-param (make-param :value 0.0))
        (gain-2 (create-gain :channels 1))
        (gain-2-param (make-param :value 100.0)))
    (build (gain-1
            :input (osc-1
                    :frequency (+ frequency-1-param
                                  (gain-2
                                   :input (osc-2
                                           :frequency frequency-2-param)
                                   :gain gain-2-param)))
            :gain gain-1-param)
           output)
    (list :noteon
          (lambda (time &key frequency)
            (multi-oscillator-set-phase osc-1
                                        :time time
                                        :phase 0)
            (multi-oscillator-set-phase osc-2
                                        :time time
                                        :phase 0)
            (param-set-value frequency-1-param
                             :time time
                             :value frequency)
            (param-set-value frequency-2-param
                             :time time
                             :value (* frequency 12.01))
            (param-cancel-and-hold gain-1-param time)
            (param-exponential-ramp gain-1-param
                                    :time time
                                    :duration 3
                                    :start-value 1
                                    :end-value 0.4)
            (param-cancel-and-hold gain-2-param time)
            (param-exponential-ramp gain-2-param
                                    :time time
                                    :duration 3
                                    :start-value 1000
                                    :end-value 10))
          :noteoff
          (lambda (time)
            (param-cancel-and-hold gain-1-param time)
            (param-set-target gain-1-param
                              :time time
                              :start-value (param-get-value gain-1-param time)
                              :target-value 0.0
                              :time-constant 0.1)
            (param-cancel-and-hold gain-2-param time)
            (param-set-target gain-2-param
                              :time time
                              :start-value (param-get-value gain-2-param time)
                              :target-value 0.0
                              :time-constant 0.1)))))

(defun create-synth-2 (voices-num)
  (defun noteon (voice &rest rest)
    (apply (getf voice :noteon) rest))
  (defun noteoff (voice &rest rest)
    (apply (getf voice :noteoff) rest))
  (let* ((input (corn.node:make-input :channels 2))
         (voices (loop
                   repeat voices-num
                   collect (make-voice-2 input)))
         (voice-manager (create-voice-manager :nodes voices
                                              :noteon #'noteon
                                              :noteoff #'noteoff)))
    (make-synth :channels 2
                :input input
                :voice-manager voice-manager)))

(defun make-voice-3 (output)
  (let ((osc-1 (make-multi-oscillator :channels 2 :type :sawtooth))
        (frequency-1-param (make-param :value 440))
        (osc-2 (make-multi-oscillator :channels 2 :type :sawtooth))
        (frequency-2-param (make-param :value 441))
        (osc-3 (make-multi-oscillator :channels 2 :type :sawtooth))
        (frequency-3-param (make-param :value 442))
        (gain (create-gain :channels 2))
        (gain-param (make-param :value 0.0)))
    (build (gain
            :input (+ (osc-1
                       :frequency frequency-1-param)
                      (osc-2
                       :frequency frequency-2-param)
                      (osc-3
                       :frequency frequency-3-param))
            :gain gain-param)
           output)
    (list :noteon
          (lambda (time &key frequency)
            (param-set-value frequency-1-param
                             :time time
                             :value frequency)
            (param-set-value frequency-2-param
                             :time time
                             :value (* frequency 1.001))
            (param-set-value frequency-3-param
                             :time time
                             :value (* frequency 0.999))
            (param-cancel-and-hold gain-param time)
            (param-exponential-ramp gain-param
                                    :time time
                                    :duration 2
                                    :start-value 0.05
                                    :end-value 0.005))
          :noteoff
          (lambda (time)
            (param-cancel-and-hold gain-param time)
            (param-set-target gain-param
                              :time time
                              :start-value (param-get-value gain-param time)
                              :target-value 0.0
                              :time-constant 0.02)))))

(defun create-synth-3 (voices-num)
  (defun noteon (voice &rest rest)
    (apply (getf voice :noteon) rest))
  (defun noteoff (voice &rest rest)
    (apply (getf voice :noteoff) rest))
  (let* ((input (corn.node:make-input :channels 2))
         (voices (loop
                   repeat voices-num
                   collect (make-voice-3 input)))
         (voice-manager (create-voice-manager :nodes voices
                                              :noteon #'noteon
                                              :noteoff #'noteoff)))
    (make-synth :channels 2
                :input input
                :voice-manager voice-manager)))


(start)

(defparameter synth-1 (create-synth-2 4))
(defparameter synth-2 (create-synth-1 4))
(defparameter synth-3 (create-synth-3 4))
(set-render
 (build-render
  (build ((create-clip :channels 2 :gain 1.0)
          :input (+ ((create-gain :channels 2)
                     :input synth-1
                     :gain ((make-param :value 0.2)))
                    ((create-gain :channels 2)
                       :input synth-2
                       :gain ((make-param :value 0.2)))
                    ((create-gain :channels 2)
                       :input ((create-pan :channels 2)
                               :pan ((make-multi-oscillator :channels 1 :type :sine)
                                     :frequency ((make-param :value 2)))
                               :input synth-3)
                       :gain ((make-param :value 0.2))))))))

(defmacro n (n x)
  (+ (* (+ n 1) 12)
     (ecase x
       (c 0) (c+ 1) (d 2) (d+ 3) (e 4) (f 5) (f+ 6) (g 7) (g+ 8) (a 9) (a+ 10) (b 11))))

(let* ((time (+ (current-time) 0.1))
       (time-1 time)
       (time-2 time)
       (time-3 time)
       (beat 0.25))
  (flet ((note-1 (d notenum)
           (synth-noteon synth-1 :time time-1 :notenum notenum)
           (synth-noteoff synth-1 :time (incf time-1 (* d beat)) :notenum notenum))
         (note-2 (notenum)
           (synth-noteon synth-2 :time time-2 :notenum notenum)
           (synth-noteoff synth-2 :time (incf time-2 beat) :notenum notenum))
         (note-3 (d &rest notenums)
           (dolist (notenum notenums)
             (synth-noteon synth-3 :time time-3 :notenum notenum)
             (synth-noteoff synth-3 :time (+ time-3 (* d 0.9 beat)) :notenum notenum))
           (incf time-3 (* d beat))))
    (dotimes (j 2)
    (dotimes (i 2)
      (dolist (n (list (n 4 c) (n 4 f) (n 4 g) (n 4 f)))
        (note-2 n)))
    (dotimes (i 2)
        (dolist (n (list (n 3 b) (n 4 f) (n 4 g) (n 4 f)))
          (note-2 n)))
    (dotimes (i 2)
        (dolist (n (list (n 3 a+) (n 4 f) (n 4 g) (n 4 f)))
          (note-2 n)))
    (dotimes (i 2)
        (dolist (n (list (n 3 a) (n 4 e) (n 4 g) (n 4 e)))
          (note-2 n)))
    (dotimes (i 2)
        (dolist (n (list (n 3 g+) (n 4 c) (n 4 g) (n 4 c)))
          (note-2 n)))
    (dotimes (i 2)
        (dolist (n (list (n 3 g) (n 3 b) (n 4 g) (n 3 b)))
          (note-2 n)))
    (dotimes (i 2)
        (dolist (n (list (n 3 f+) (n 3 a+) (n 4 g) (n 3 a+)))
          (note-2 n)))
    (dolist (n (list (n 3 g+) (n 4 c) (n 4 d+) (n 4 c)))
      (note-2 n))
    (dolist (n (list (n 3 g+) (n 4 c) (n 4 g+) (n 4 d+)))
      (note-2 n))
    (dotimes (i 3)
      (note-1 3 (n 4 g))
      (note-1 1 (n 4 f))
      (note-1 3 (n 5 c))
      (note-1 1 (n 4 f)))
    (note-1 3 (n 4 a))
    (note-1 1 (n 4 a+))
    (note-1 2 (n 4 a))
    (note-1 2 (n 4 g))
    (note-1 3 (n 4 f))
    (note-1 3 (n 4 c))
    (note-1 1 (n 4 f))
    (note-1 1 (n 4 g))
    (note-1 3 (n 4 f))
    (note-1 3 (n 4 c))
    (note-1 2 (n 3 a))
    (note-1 3 (n 3 a+))
    (note-1 3 (n 4 c))
    (note-1 2 (n 4 c+))
    (note-1 2 (n 4 d+))
    (note-1 2 (n 3 g+))
    (note-1 2 (n 4 g+))
    (note-1 2 (n 4 f+))
    (dolist (n `((,(n 4 g) ,(n 5 c))
                 (,(n 4 g) ,(n 5 c))
                 (,(n 4 g) ,(n 5 c))
                 (,(n 4 g) ,(n 5 c))
                 (,(n 4 g) ,(n 5 c))
                 (,(n 4 g) ,(n 5 c))
                 (,(n 4 f) ,(n 5 c))
                 (,(n 4 g+) ,(n 5 c))))
      (incf time-3 (* 1 beat))
      (note-3 1 (first n) (second n))
      (note-3 2 (first n) (second n))
      (note-3 1 (first n) (second n))
      (note-3 2 (first n) (second n))
      (note-3 1 (first n) (second n)))
      )
    ; outro
    (dotimes (i 2)
      (dolist (n (list (n 4 c) (n 4 f) (n 4 g) (n 4 f)))
        (note-2 n)))
    (synth-noteon synth-2 :time time-2 :notenum (n 4 c))
    (synth-noteoff synth-2 :time (+ time-2 (* 4 beat)) :notenum (n 4 c))
    (note-1 7 (n 4 g))
    (incf time-3 (* 1 beat))
    (note-3 1 (n 4 g) (n 5 c))
    (note-3 2 (n 4 g) (n 5 c))
    (note-3 1 (n 4 g) (n 5 c))
    (note-3 2 (n 4 g) (n 5 c))
    (note-3 1 (n 4 g) (n 5 c))
    (note-3 8 (n 4 g) (n 5 c))
    ))
