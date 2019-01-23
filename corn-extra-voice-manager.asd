#|
  This file is a part of corn project.
  Copyright (c) 2018 carrotflakes (carrotflakes@gmail.com)
|#

#|
  Author: carrotflakes (carrotflakes@gmail.com)
|#

(defsystem "corn-extra-voice-manager"
  :version "0.1.0"
  :author "carrotflakes"
  :license "LLGPL"
  :depends-on ()
  :components ((:module "src/extra"
                :components
                ((:file "voice-manager"))))
  :description "Voice-manager for polyphonic synthesizer"
  ;:in-order-to ((test-op (test-op "corn-test")))
  )
