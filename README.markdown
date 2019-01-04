# Corn
Primitive sound generation system.

## Usage

``` lisp
(defvar wave-table (create-wave-table :sin :sampling-rate 44100 :interpolate :linear))

(start)

(defvar synth
    (make-synth (gain (adsr 1 0 0.1 0.6 0.2) (osc :sin))))

(defvar master-mixer (make-mixer *destination* :effectors '()))

(put (make-note-event synth :time time :notenum 60 :duration 0))
(put (make-audio-event wave :time time :rate 1 :duration 0))
```

## Installation
Requiring [portaudio](http://www.portaudio.com/).

```
ros install carrotflakes/corn
```

## Author

* carrotflakes (carrotflakes@gmail.com)

## Copyright

Copyright (c) 2018 carrotflakes (carrotflakes@gmail.com)

## License

Licensed under the LLGPL License.
