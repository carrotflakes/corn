#|
  This file is a part of corn project.
  Copyright (c) 2018 carrotflakes (carrotflakes@gmail.com)
|#

#|
  Author: carrotflakes (carrotflakes@gmail.com)
|#

(defsystem "corn"
  :version "0.1.0"
  :author "carrotflakes"
  :license "LLGPL"
  :depends-on ("cl-portaudio"
               "bordeaux-threads"
               "queues.priority-cqueue"
               "alexandria")
  :components ((:module "src"
                :components
                ((:file "corn"
                  :depends-on ("parameters"
                               "buffer"
                               "node"
                               "render"))
                 (:file "render"
                  :depends-on ("parameters"
                               "buffer"
                               "event"
                               "node"))
                 (:file "buffer"
                  :depends-on ("parameters"))
                 (:file "event")
                 (:file "node"
                  :depends-on ("parameters"))
                 (:file "util")
                 (:file "parameters")
                 (:file "node/nop"
                  :depends-on ("node"
                               "parameters"))
                 (:file "node/sine"
                  :depends-on ("node"
                               "parameters"
                               "node/param"))
                 (:file "node/gain"
                  :depends-on ("node"
                               "parameters"
                               "node/param"))
                 (:file "node/pan"
                  :depends-on ("node"
                               "parameters"
                               "node/param"
                               "util"))
                 (:file "node/delay"
                  :depends-on ("node"
                               "parameters"
                               "buffer"
                               "node/param"))
                 (:file "node/sawtooth"
                  :depends-on ("node"
                               "parameters"
                               "node/param"))
                 (:file "node/biquad-filter"
                  :depends-on ("node"
                               "parameters"
                               "node/param"
                               "buffer"))
                 (:file "node/buffer"
                  :depends-on ("node"
                               "parameters"))
                 (:file "node/param"
                  :depends-on ("node"
                               "parameters"
                               "event")))))
  :description "Primitive sound generation system"
  :long-description
  #.(read-file-string
     (subpathname *load-pathname* "README.markdown"))
  :in-order-to ((test-op (test-op "corn-test"))))
