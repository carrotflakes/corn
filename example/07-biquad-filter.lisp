(ql:quickload '(:corn
                :corn-nodes
                :corn-extra-node-builder))

(use-package '(:corn
               :corn.node.multi-oscillator
               :corn.node.param
               :corn.node.gain
               :corn.node.biquad-filter
               :corn.extra.node-builder))

(defvar frequency (make-param :value 440))
(defvar filter (create-biquad-filter :channels 2 :type :low-pass))
(defvar filter-frequency (make-param :value 800))
(defvar filter-gain (make-param :value 10))
(defvar filter-q (make-param :value 2))

(set-render
 (build-render
  (build
   (filter
    :frequency filter-frequency
    :gain filter-gain
    :q filter-q
    :input ((make-multi-oscillator :channels 2
                                   :type :sawtooth)
            :frequency frequency)))))

(start)

(defun rotate-filter-type ()
  (dolist (type '(:low-pass :high-pass :band-pass :low-shelf :high-shelf :peaking :notch :all-pass))
    (print type)
    (setf (biquad-filter-type filter) type)
    (sleep 1)))
(rotate-filter-type)
