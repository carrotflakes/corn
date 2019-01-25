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
               :corn.node.clip
               :corn.util
               :corn.extra.voice-manager
               :corn.extra.node-builder))

(defun make-voice (output)
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
    (list :multi-oscillator multi-oscillator
          :frequency-param frequency-param
          :filter-frequency-param filter-frequency-param
          :gain-param gain-param)))

(defmacro with-plist (keys plist &body body)
  (alexandria:once-only (plist)
    `(let ,(loop
             for key in keys
             collect `(,key (getf ,plist ,(intern (symbol-name key) :keyword))))
       ,@body)))

(defun voice-noteon (voice time &key frequency)
  (with-plist (multi-oscillator gain-param frequency-param filter-frequency-param) voice
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
    (param-exponential-ramp filter-frequency-param
                            :time time
                            :duration 0.5
                            :start-value 2000
                            :end-value 400)))

(defun voice-noteoff (voice time)
  (with-plist (gain-param filter-frequency-param) voice
    (param-cancel-and-hold gain-param time)
    (param-set-target gain-param
                      :time time
                      :start-value (param-get-value gain-param time)
                      :target-value 0.0
                      :time-constant 0.1)
    (param-cancel-and-hold filter-frequency-param time)))

(defstruct (synth (:include nop))
  voice-manager)

(defun create-synth (voices-num)
  (let* ((input (corn.node:make-input :channels 2))
         (voices (loop
                   repeat voices-num
                   collect (make-voice input)))
         (voice-manager (create-voice-manager :nodes voices
                                              :noteon #'voice-noteon
                                              :noteoff #'voice-noteoff)))
    (make-synth :channels 2
                :input input
                :voice-manager voice-manager)))

(defun synth-noteon (synth &key time notenum)
  (voice-manager-noteon (synth-voice-manager synth) notenum time
                        :frequency (notenum-frequency notenum)))

(defun synth-noteoff (synth &key time notenum)
  (voice-manager-noteoff (synth-voice-manager synth) notenum time))

(defvar synth (create-synth 10))

(set-render
 (build-render 
  (build ((create-clip :channels 2 :gain 1.0)
          :input ((create-gain :channels 2)
                  :input synth
                  :gain ((make-param :value 0.2)))))))

(start)

(defun play (score)
  (let ((time (+ (current-time) 1)))
    (loop
      for (beat duration notenum) in score
      for start-time = (+ time (* beat 0.5))
      for end-time = (+ start-time (* duration 0.5))
      do (synth-noteon synth :time start-time :notenum notenum)
         (synth-noteoff synth :time end-time :notenum notenum))))

(play
  '((0 1.8 60)
    (0 1.8 64)
    (0 1.8 67)
    (0 1.8 72)
    (2 1.8 60)
    (2 1.8 62)
    (2 1.8 65)
    (2 1.8 71)
    (4 1.8 60)
    (4 1.8 64)
    (4 1.8 67)
    (4 1.8 72)))
