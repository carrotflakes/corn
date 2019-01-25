(ql:quickload '(:corn
                :corn-nodes
                :corn-extra-node-builder))

(use-package '(:corn
               :corn.node.sine
               :corn.node.param
               :corn.extra.node-builder))

(defvar frequency (make-param :value 440))

(set-render (build-render (build ((make-sine :channels 2)
                                  :frequency frequency))))

(start)

(let ((time (current-time)))
  (param-set-value frequency
                   :time (incf time 1)
                   :value 880)
  (param-linear-ramp frequency
                     :time (incf time 1)
                     :duration 0.8
                     :start-value 440
                     :end-value 880)
  (param-exponential-ramp frequency
                          :time (incf time 1)
                          :duration 0.8
                          :start-value 440
                          :end-value 880)
  (param-set-target frequency
                    :time (incf time 1)
                    :start-value 880
                    :target-value 440
                    :time-constant 1))
