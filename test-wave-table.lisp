(ql:quickload :corn)

(use-package '(:corn
               :corn.defnode
               :corn.node.sawtooth
               :corn.node.param
               :corn.node.gain
               :corn.node.wave-table
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
      (wave-table (create-wave-table :buffer (make-wave 44100)
                                     :loop t
                                     :pointer 0))
      (pitch-param (make-param :value 1)))
  (connect pitch-param (wave-table-pitch wave-table))
  (connect wave-table master)
  (set-render (build-render master)))
