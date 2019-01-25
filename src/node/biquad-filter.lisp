(defpackage corn.node.biquad-filter
  (:use :cl
        :corn.node
        :corn.node.param
        :corn.parameters
        :corn.buffer)
  (:import-from :alexandria
                :with-gensyms)
  (:export :make-biquad-filter
           :create-biquad-filter
           :biquad-filter-type
           :biquad-filter-input
           :biquad-filter-frequency
           :biquad-filter-gain
           :biquad-filter-q))
(in-package :corn.node.biquad-filter)

(defstruct (biquad-filter (:include node))
  input
  type
  (frequency (make-input :channels 1
                         :default-sample-1 0.0))
  (gain (make-input :channels 1
                    :default-sample-1 0.0))
  (q (make-input :channels 1
                 :default-sample-1 0.0))
  samples)

(defun create-biquad-filter (&key type channels)
  (make-biquad-filter :channels channels
                      :input (make-input :channels channels
                                         :default-sample-1 0.0
                                         :default-sample-2 0.0)
                      :type type
                      :samples (make-buffer 4 channels)))

(declaim (inline parameters))
(defun parameters (type frequency gain q)
  (let* ((a (expt 10 (/ gain 40)))
         (w0 (float (/ (* 2 pi frequency) *sampling-rate*) 0.0))
         (cos (cos w0))
         (sin (sin w0))
         (alpha (/ sin (* 2 q))))
  (ecase type
    (:low-pass
     (values (+ 1 alpha)
             (* -2 cos)
             (- 1 alpha)
             (/ (- 1 cos) 2)
             (- 1 cos)
             (/ (- 1 cos) 2)))
    (:high-pass
     (values (+ 1 alpha)
             (* -2 cos)
             (- 1 alpha)
             (/ (+ 1 cos) 2)
             (- (+ 1 cos))
             (/ (+ 1 cos) 2)))
    (:band-pass
     (values (+ 1 alpha)
             (* -2 cos)
             (- 1 alpha)
             alpha
             0.0
             (- alpha)))
    (:low-shelf
     (values (+ (+ a 1) (* (- a 1) cos) (* 2 (sqrt a) alpha))
             (* -2 (+ (- a 1) (* (+ a 1) cos)))
             (- (+ (+ a 1) (* (- a 1) cos)) (* 2 (sqrt a) alpha))
             (* a (+ (+ a 1) (- (* (- a 1) cos)) (* 2 (sqrt a) alpha)))
             (* 2 a (- (- a 1) (* (+ a 1) cos)))
             (* a (- (+ a 1) (* (- a 1) cos) (* 2 (sqrt a) alpha)))))
    (:high-shelf
     (values (+ (+ a 1) (- (* (- a 1) cos)) (* 2 (sqrt a) alpha))
             (* 2 (- (- a 1) (* (+ a 1) cos)))
             (- (+ a 1) (* (- a 1) cos) (* 2 (sqrt a) alpha))
             (* a (+ (+ a 1) (* (- a 1) cos) (* 2 (sqrt a) alpha)))
             (* -2 a (+ (- a 1) (* (+ a 1) cos)))
             (* a (+ (+ a 1) (* (- a 1) cos) (- (* 2 (sqrt a) alpha))))))
    (:peaking
     (values (+ 1 (/ alpha a))
             (* -2 cos)
             (- 1 (/ alpha a))
             (+ 1 (* alpha a))
             (* -2 cos)
             (- 1 (* alpha a))))
    (:notch
     (values (+ 1 alpha)
             (* -2 cos)
             (- 1 alpha)
             1
             (* -2 cos)
             1))
    (:all-pass
     (values (+ 1 alpha)
             (* -2 cos)
             (- 1 alpha)
             (- 1 alpha)
             (* -2 cos)
             (+ 1 alpha))))))

(defmacro with-input-parts* (list &body body)
  (let ((parts (copy-list '(bindings () initialize () update () finalize ()))))
    (labels
        ((f (list)
           (if list
               (destructuring-bind ((prefix form) . list) list
                 `(with-input-parts
                      ,(loop
                         for suffix in '(bindings initialize update sample-1 sample-2 finalize)
                         for symbol = (intern (format nil "~a-~a" prefix suffix))
                         do (push symbol (getf parts suffix))
                         collect symbol)
                    ,form
                    ,(f list)))
               `(let ,(loop
                        for x in '(bindings initialize update finalize)
                        collect `(,x (concatenate 'list ,@(nreverse (getf parts x)))))
                  ,@body))))
      (f list))))

(defmethod node-parts ((biquad-filter biquad-filter))
  (with-input-parts*
      ((input (biquad-filter-input biquad-filter))
       (frequency (biquad-filter-frequency biquad-filter))
       (gain (biquad-filter-gain biquad-filter))
       (q (biquad-filter-q biquad-filter)))
    (ecase (biquad-filter-channels biquad-filter)
      (1 (with-gensyms (type sample a0 a1 a2 b0 b1 b2 i1 i2 o1 o2)
           `(:bindings (,@bindings
                        (,type (biquad-filter-type ,biquad-filter))
                        (,sample)
                        (,a0) (,a1) (,a2) (,b0) (,b1) (,b2)
                        (,i1 (aref (biquad-filter-samples ,biquad-filter) 0 0))
                        (,i2 (aref (biquad-filter-samples ,biquad-filter) 0 1))
                        (,o1 (aref (biquad-filter-samples ,biquad-filter) 0 2))
                        (,o2 (aref (biquad-filter-samples ,biquad-filter) 0 3)))
             :initialize ,initialize
             :update (,@update
                      (multiple-value-setq (,a0 ,a1 ,a2 ,b0 ,b1 ,b2)
                        (parameters ,type ,frequency-sample-1 ,gain-sample-1 ,q-sample-1))
                      (setf ,sample (- (+ (* (/ ,b0 ,a0) ,input-sample-1)
                                          (* (/ ,b1 ,a0) ,i1)
                                          (* (/ ,b2 ,a0) ,i2))
                                       (* (/ ,a1 ,a0) ,o1)
                                       (* (/ ,a2 ,a0) ,o2))
                            ,i2 ,i1
                            ,i1 ,input-sample-1
                            ,o2 ,o1
                            ,o1 ,sample))
             :sample-1 ,sample
             :finalize (,@finalize
                        (setf (aref (biquad-filter-samples ,biquad-filter) 0 0) i1
                              (aref (biquad-filter-samples ,biquad-filter) 0 1) i2
                              (aref (biquad-filter-samples ,biquad-filter) 0 2) o1
                              (aref (biquad-filter-samples ,biquad-filter) 0 3) o2)))))
      (2 (with-gensyms (type sample-1 sample-2
                             a0 a1 a2 b0 b1 b2 i11 i21 o11 o21 i12 i22 o12 o22)
           `(:bindings (,@bindings
                        (,type (biquad-filter-type ,biquad-filter))
                        (,sample-1) (,sample-2)
                        (,a0) (,a1) (,a2) (,b0) (,b1) (,b2)
                        (,i11 (aref (biquad-filter-samples ,biquad-filter) 0 0))
                        (,i21 (aref (biquad-filter-samples ,biquad-filter) 0 1))
                        (,o11 (aref (biquad-filter-samples ,biquad-filter) 0 2))
                        (,o21 (aref (biquad-filter-samples ,biquad-filter) 0 3))
                        (,i12 (aref (biquad-filter-samples ,biquad-filter) 1 0))
                        (,i22 (aref (biquad-filter-samples ,biquad-filter) 1 1))
                        (,o12 (aref (biquad-filter-samples ,biquad-filter) 1 2))
                        (,o22 (aref (biquad-filter-samples ,biquad-filter) 1 3)))
             :initialize ,initialize
             :update (,@update
                      (multiple-value-setq (,a0 ,a1 ,a2 ,b0 ,b1 ,b2)
                        (parameters ,type ,frequency-sample-1 ,gain-sample-1 ,q-sample-1))
                      (setf ,sample-1 (- (+ (* (/ ,b0 ,a0) ,input-sample-1)
                                            (* (/ ,b1 ,a0) ,i11)
                                            (* (/ ,b2 ,a0) ,i21))
                                         (* (/ ,a1 ,a0) ,o11)
                                         (* (/ ,a2 ,a0) ,o21))
                            ,i21 ,i11
                            ,i11 ,input-sample-1
                            ,o21 ,o11
                            ,o11 ,sample-1
                            ,sample-2 (- (+ (* (/ ,b0 ,a0) ,input-sample-2)
                                            (* (/ ,b1 ,a0) ,i12)
                                            (* (/ ,b2 ,a0) ,i22))
                                         (* (/ ,a1 ,a0) ,o12)
                                         (* (/ ,a2 ,a0) ,o22))
                            ,i22 ,i12
                            ,i12 ,input-sample-2
                            ,o22 ,o12
                            ,o12 ,sample-2))
             :sample-1 ,sample-1
             :sample-2 ,sample-2
             :finalize (,@finalize
                        (setf (aref (biquad-filter-samples ,biquad-filter) 0 0) ,i11
                              (aref (biquad-filter-samples ,biquad-filter) 0 1) ,i21
                              (aref (biquad-filter-samples ,biquad-filter) 0 2) ,o11
                              (aref (biquad-filter-samples ,biquad-filter) 0 3) ,o21
                              (aref (biquad-filter-samples ,biquad-filter) 1 0) ,i12
                              (aref (biquad-filter-samples ,biquad-filter) 1 1) ,i22
                              (aref (biquad-filter-samples ,biquad-filter) 1 2) ,o12
                              (aref (biquad-filter-samples ,biquad-filter) 1 3) ,o22))))))))
