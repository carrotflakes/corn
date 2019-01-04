#|
  This file is a part of corn project.
  Copyright (c) 2018 carrotflakes (carrotflakes@gmail.com)
|#

(defsystem "corn-test"
  :defsystem-depends-on ("prove-asdf")
  :author "carrotflakes"
  :license "LLGPL"
  :depends-on ("corn"
               "prove")
  :components ((:module "tests"
                :components
                ((:test-file "corn"))))
  :description "Test system for corn"

  :perform (test-op (op c) (symbol-call :prove-asdf :run-test-system c)))
