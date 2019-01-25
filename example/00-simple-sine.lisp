(ql:quickload '(:corn
                :corn-nodes))

(use-package '(:corn
               :corn.node.sine
               :corn.node.param))

(defvar sine (make-sine :channels 2))
(defvar frequency-param (make-param :value 440))
(defvar destination (make-destination))

(connect frequency-param (sine-frequency sine))
(connect sine destination)

(set-render (build-render destination))

(start)
