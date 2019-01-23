#|
  This file is a part of corn project.
  Copyright (c) 2018 carrotflakes (carrotflakes@gmail.com)
|#

#|
  Author: carrotflakes (carrotflakes@gmail.com)
|#

(defsystem "corn-extra-node-builder"
  :version "0.1.0"
  :author "carrotflakes"
  :license "LLGPL"
  :depends-on ()
  :components ((:module "src/extra"
                :components
                ((:file "node-builder"))))
  :description "Corn node-builder"
  ;:in-order-to ((test-op (test-op "corn-test")))
  )
