(ql:quickload '(:corn
                :corn-nodes
                :corn-extra-node-builder))

(use-package '(:corn
               :corn.node.sine
               :corn.node.param
               :corn.extra.node-builder))

(set-render (build-render (build ((make-sine :channels 2)
                                  :frequency ((make-param :value 440))))))

(start)
