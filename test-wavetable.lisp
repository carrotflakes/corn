(ql:quickload :corn)

(use-package '(:corn
               :corn.defnode
               :corn.node.sawtooth
               :corn.node.param
               :corn.node.gain
               :corn.node.wavetable
               :corn.util))

(start)

(defun make-wave (&optional (size 44100))
  (loop
    with buffer = (corn.buffer:make-buffer size 2)
    for i below size
    for g = (/ (- size i) size)
    for x = (* (sin (+ (* 0.1 i) (* g 5 (sin (* 0.049 i))))) g)
    do (setf (aref buffer 0 i) (float x 0.0)
             (aref buffer 1 i) (float x 0.0))
    finally (return buffer)))

(let ((master (make-destination))
      (wavetable (create-wavetable :buffer (make-wave 44100)
                                   :loop nil
                                   :pointer 0))
      (pitch-param (make-param :value 1)))
  (connect pitch-param (wavetable-pitch wavetable))
  (connect wavetable master)
  (set-render (build-render master))
  (let ((time (current-time)))
    (loop
      for i from 1 below 10
      do (wavetable-set-point wavetable :time (incf time (* i 0.05)) :pointer 0))
    (loop
      for i from 1 below 10
      do (wavetable-set-point wavetable :time (incf time 1) :pointer (* i 4000)))))

(stop)
