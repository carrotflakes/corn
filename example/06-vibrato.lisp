(ql:quickload '(:corn
                :corn-nodes
                :corn-extra-node-builder))

(use-package '(:corn
               :corn.node.multi-oscillator
               :corn.node.param
               :corn.node.gain
               :corn.extra.node-builder))

(defvar frequency (make-param :value 440))
(defvar vibrato-frequency (make-param :value 5))
(defvar vibrato-depth (make-param :value 8))

(set-render
 (build-render
  (build
   ((make-multi-oscillator :channels 2
                           :type :sawtooth)
    :frequency (+ frequency
                  ((create-gain :channels 1)
                   :input ((make-multi-oscillator :channels 1
                                                  :type :sine)
                           :frequency vibrato-frequency)
                   :gain vibrato-depth))))))

(start)
