(ql:quickload '(:corn
                :corn-nodes
                :corn-extra-node-builder))

(use-package '(:corn
               :corn.node.multi-oscillator
               :corn.node.param
               :corn.extra.node-builder))

(defvar frequency (make-param :value 440))
(defvar oscillator (make-multi-oscillator :channels 2
                                          :type :sine))

(set-render
 (build-render
  (build
   (oscillator
    :frequency frequency))))

(start)

(sleep 1)
(setf (multi-oscillator-type oscillator) :square)
(sleep 1)
(setf (multi-oscillator-type oscillator) :triangle)
(sleep 1)
(setf (multi-oscillator-type oscillator) :sawtooth)
(sleep 1)
(setf (multi-oscillator-type oscillator) :sine)
