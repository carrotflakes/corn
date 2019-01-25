(ql:quickload '(:corn
                :corn-nodes
                :corn-extra-node-builder))

(use-package '(:corn
               :corn.node.sine
               :corn.node.param
               :corn.node.gain
               :corn.extra.node-builder))

(defvar frequency (make-param :value 440))
(defvar gain (make-param :value 1.0))

(set-render
 (build-render
  (build
   ((create-gain :channels 2)
    :input ((make-sine :channels 2)
            :frequency frequency)
    :gain gain))))

(start)

(let ((time (current-time)))
  (param-set-value gain
                   :time (incf time 0.5)
                   :value 0)
  (param-set-value gain
                   :time (incf time 0.5)
                   :value 0.5)
  (param-set-value gain
                   :time (incf time 0.5)
                   :value 1.0)
  (param-set-target gain
                    :time (incf time 0.5)
                    :start-value 1.0
                    :target-value 0
                    :time-constant 1))
