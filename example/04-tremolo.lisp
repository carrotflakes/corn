(ql:quickload '(:corn
                :corn-nodes
                :corn-extra-node-builder))

(use-package '(:corn
               :corn.node.sine
               :corn.node.param
               :corn.node.gain
               :corn.extra.node-builder))

(defvar frequency (make-param :value 440))
(defvar tremolo-frequency (make-param :value 8))

(set-render
 (build-render
  (build
   ((create-gain :channels 2)
    :input ((make-sine :channels 2)
            :frequency frequency)
    :gain (+ ((make-param :value 0.5))
             ((create-gain :channels 1)
              :input ((make-sine :channels 1)
                      :frequency tremolo-frequency)
              :gain ((make-param :value 0.5))))))))

(start)
