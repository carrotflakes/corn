(defpackage corn.node.pan
  (:use :cl
        :corn.node
        :corn.node.param
        :corn.parameters)
  (:import-from :corn.util
                :clamp)
  (:import-from :alexandria
                :with-gensyms)
  (:export :make-pan
           :create-pan
           :pan-input
           :pan-pan))
(in-package :corn.node.pan)

(defstruct (pan (:include node (corn.node::channels 2)))
  input
  (pan (make-input :channels 1
                   :default-sample-1 0.0)))

(defun create-pan (&key channels)
  (make-pan :input (make-input :channels channels
                               :default-sample-1 0.0
                               :default-sample-2 0.0)))

(defmethod node-parts ((pan pan))
  (with-input-parts
      (input-bindings
       input-initialize
       input-update
       input-sample-1
       input-sample-2
       input-finalize)
      (pan-input pan)
    (with-input-parts
        (pan-bindings
         pan-initialize
         pan-update
         pan-sample-1
         pan-sample-2
         pan-finalize)
        (pan-pan pan)
      (ecase (io-channels (pan-input pan))
        (1 (with-gensyms (phase)
             `(:bindings (,@input-bindings
                          ,@pan-bindings
                          (,phase))
               :initialize (,@input-initialize ,@pan-initialize)
               :update (,@input-update
                        ,@pan-update
                        (setf ,phase (* (/ (+ (clamp ,pan-sample-1 -1.0 1.0) 1) 2) pi 0.5)))
               :sample-1 (* ,input-sample-1 (float (cos ,phase) 0.0))
               :sample-2 (* ,input-sample-1 (float (sin ,phase) 0.0))
               :finalize (,@input-finalize ,@pan-finalize))))
        (2 (with-gensyms (output-l output-r)
             `(:bindings (,@input-bindings
                          ,@pan-bindings
                          (,output-l)
                          (,output-r))
               :initialize (,@input-initialize ,@pan-initialize)
               :update (,@input-update
                        ,@pan-update
                        (let* ((pan ,pan-sample-1)
                               (phase (* (+ (clamp pan -1.0 1.0) (if (<= pan 0) 1 0)) pi 0.5))
                               (gain-l (cos phase))
                               (gain-r (sin phase)))
                          (if (<= pan 0)
                              (setf ,output-l (+ ,input-sample-1
                                                 (* ,input-sample-2 gain-l))
                                    ,output-r (* ,input-sample-2 gain-r))
                              (setf ,output-l (* ,input-sample-1 gain-l)
                                    ,output-r (+ ,input-sample-2
                                                 (* ,input-sample-1 gain-r))))))
               :sample-1 (float ,output-l 0.0)
               :sample-2 (float ,output-r 0.0)
               :finalize (,@input-finalize ,@pan-finalize))))))))

#|
pan = min(1, max(-1, pan));
if (mono) {
  x = (pan + 1) / 2;
} else {
  if (pan <= 0)
    x = pan + 1;
  else
    x = pan;
}
gainL = cos(x * Math.PI / 2);
gainR = sin(x * Math.PI / 2);
if (mono) {
  outputL = input * gainL
  outputR = input * gainR
} else {
  if (pan <= 0) {
    outputL = inputL + inputR * gainL;
    outputR = inputR * gainR;
  } else {
    outputL = inputL * gainL;
    outputR = inputR + inputL * gainR;
  }
}
|#
