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
               "queues.priority-cqueue")
  :components ((:module "src"
                :components
                ((:file "corn"
                  :depends-on ("parameters"
                               "buffer"
                               "general-node"
                               "render"))
                 (:file "render"
                  :depends-on ("parameters"
                               "buffer"
                               "event"
                               "general-node"
                               "node/mixer"
                               "node/test-tone"))
                 (:file "buffer"
                  :depends-on ("parameters"))
                 (:file "event")
                 (:file "general-node")
                 (:file "parameters")
                 (:file "node/mixer"
                  :depends-on ("buffer"
                               "parameters"
                               "node/audio-node"))
                 (:file "node/test-tone"
                  :depends-on ("node/audio-node"))
                 (:file "node/audio-node"
                  :depends-on ("general-node")))))
  :description "Primitive sound generation system"
  :long-description
  #.(read-file-string
     (subpathname *load-pathname* "README.markdown"))
  :in-order-to ((test-op (test-op "corn-test"))))
