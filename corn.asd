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
               "bordeaux-threads")
  :components ((:module "src"
                :components
                ((:file "corn" :depends-on ("parameters" "buffer" "render"))
                 (:file "render" :depends-on ("parameters" "buffer"))
                 (:file "buffer" :depends-on ("parameters"))
                 (:file "parameters"))))
  :description "Primitive sound generation system"
  :long-description
  #.(read-file-string
     (subpathname *load-pathname* "README.markdown"))
  :in-order-to ((test-op (test-op "corn-test"))))
