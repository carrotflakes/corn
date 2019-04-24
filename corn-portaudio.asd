#|
  This file is a part of corn project.
  Copyright (c) 2018 carrotflakes (carrotflakes@gmail.com)
|#

#|
  Author: carrotflakes (carrotflakes@gmail.com)
|#

(defsystem "corn-portaudio"
  :version "0.1.0"
  :author "carrotflakes"
  :license "LLGPL"
  :depends-on ("cl-portaudio"
               "bordeaux-threads"
               "corn")
  :components ((:module "src"
                :components
                ((:file "portaudio"))))
  :description "Portaudio interface for corn")
