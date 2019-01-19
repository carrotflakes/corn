#|
  This file is a part of corn project.
  Copyright (c) 2018 carrotflakes (carrotflakes@gmail.com)
|#

#|
  Author: carrotflakes (carrotflakes@gmail.com)
|#

(defsystem "corn-nodes"
  :version "0.1.0"
  :author "carrotflakes"
  :license "LLGPL"
  :depends-on ("corn")
  :components ((:module "src/node"
                :components
                ((:file "nop")
                 (:file "sine"
                  :depends-on ("param"))
                 (:file "sawtooth"
                  :depends-on ("param"))
                 (:file "gain"
                  :depends-on ("param"))
                 (:file "pan"
                  :depends-on ("param"))
                 (:file "delay"
                  :depends-on ("param"))
                 (:file "biquad-filter"
                  :depends-on ("param"))
                 (:file "render")
                 (:file "wavetable")
                 (:file "multi-oscillator")
                 (:file "buffer")
                 (:file "param")
                 (:file "defnode"
                  :depends-on ("render")))))
  :description "Primitive corn nodes"
  ;:in-order-to ((test-op (test-op "corn-node-test")))
  )
