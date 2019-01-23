# Corn
Primitive sound generation system.

## Usage

``` lisp
; Make nodes.
(defvar sine (make-sine :channels 2))
(defvar frequency-param (make-param :value 440))
(defvar gain (create-gain :channels 2))
(defvar gain-param (make-param :value 0.5))

; And make a destination.
(defvar destination (make-destination))

; Make connections between each node, to flow to the destination.
(connect frequency-param (sine-frequency sine))
(connect gain-param (gain-gain gain))
(connect sine (gain-input gain))
(connect gain destinaion)

; Build sound renderer and set the renderer for playing.
(set-render (build-render destination))

; Activate to make sounds in real time.
(start)

; You can call `(set-render)` after `(start)` also.

(let ((time (current-time))) ; `(current-time)` returns the current time from the start. The unit is seconds and the type is ratio.

  ; Several nodes can be controlled at arbitrary timing. A typical one is `corn.node.param:param`.
  (param-set-value frequency-param :time (+ time 1) :value 880) ; Change the frequency to 880 Hz at `(+ time 1)`.
  )
```

Using `corn.extra.node-builder:build` macro simplifies the above code:

```
(set-render
 (build-render
  (build ((create-gain :channels 2)
          :input ((make-sine :channels 2)
                  :frequency ((make-param :value 440)))
          :gain ((make-param :value 0.5))))))
(start)
```

## Installation
Requiring [portaudio](http://www.portaudio.com/).

```
ros install oconnore/queues
ros install carrotflakes/corn
```

## Nodes
### nop
Nop passes through with no process.

### sine
Sine outputs sine wave with specified frequency.

### param
Param outputs control signal (e.g. envelope).

### gain
Gain amplifies signal by param.

## Author

* carrotflakes (carrotflakes@gmail.com)

## Copyright

Copyright (c) 2018 carrotflakes (carrotflakes@gmail.com)

## License

Licensed under the LLGPL License.
