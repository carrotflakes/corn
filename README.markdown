# Corn
Primitive sound generation system.

## Usage

``` lisp
; Make nodes for generating sounds.
(defvar synth (make-synth ...))
(defvar audio-clip (make-audio-clip ...))

; And make effector nodes.
(defvar effector (make-foo-effector))

; Make connections between each node, to flow to *master*.
(connect synth effector)
(connect effector *master*)
(connect audio-clip *master*)

; Activate to make sounds in real time.
(start)

; You can make nodes and connections after `(start)` also.

(let ((time (current-time))) ; `(current-time)` returns the current time from the start. The unit is seconds and the type is ratio.

  ; Schedule events, and the events will be fired at the specified time.
  (put-event (synth-event synth :time (+ time 1) :notenum 60 :velocity 0.75))
  (put-event (audio-clip-event audio-clip) :time (+ time 1) :rate 60 :duration 0.75))
```

## Installation
Requiring [portaudio](http://www.portaudio.com/).

```
ros install oconnore/queues
ros install carrotflakes/corn
```

## Author

* carrotflakes (carrotflakes@gmail.com)

## Copyright

Copyright (c) 2018 carrotflakes (carrotflakes@gmail.com)

## License

Licensed under the LLGPL License.
