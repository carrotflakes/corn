(ql:quickload :corn)

(use-package :corn)

(defvar sine (corn.node.sine:make-sine :channels 2))

(connect sine *master*)

(let ((*print-circle* t))
  (print (corn.node::render-body 'buffer *master*)))

(setf corn.render::*render* (corn.node:build-render *master*))

(start)

(sleep 10)

(stop)
