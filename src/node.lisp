(defpackage corn.node
  (:use :cl
        :corn.parameters)
  (:import-from :alexandria
                :with-gensyms)
  (:export :io
           :io-channels
           :io-nodes
           :input
           :make-input
           :input-default-sample-1
           :input-default-sample-2
           :output
           :node
           :make-node
           :node-inputs
           :connect
           :disconnect
           :node-parts
           :with-node-parts
           :with-input-parts
           :*buffer-pointer*

           :make-nop
           :make-sine
           :build-render
           ))
(in-package :corn.node)

(defstruct io
  channels
  nodes)

(defstruct (input (:include io))
  (default-sample-1 0.0)
  (default-sample-2 0.0))

(defstruct (output (:include io)))

(defstruct (node (:include output)))

;(defmethod print-object ((node node) stream)

(defgeneric node-inputs (node))
(defmethod node-inputs ((node node)) ; TODO?
  '())

(defun connect (output input)
  (assert (typep output 'output))
  (assert (typep input 'input))
  (unless (= (io-channels output) (io-channels input))
    (let ((*print-circle* t)) ; FIXME
      (print output)
      (print input))
    (error "different channel nodes are connected"))
  (pushnew output (io-nodes input))
  (pushnew input (io-nodes output)))

(defun disconnect (output input)
  (setf (io-nodes input) (remove output (io-nodes input))
        (io-nodes output) (remove input (io-nodes output))))

(defgeneric node-parts (node))
(defmethod node-parts ((node node))
  `(:bindings ()
    :initialize ()
    :update ()
    :sample-1 0.0
    :sample-2 0.0
    :finalize ()))

(defvar *node-parts-cache*)

(defmacro with-node-parts-cache (&body body)
  `(let ((*node-parts-cache* (make-hash-table :test 'eq)))
     ,@body))

(defun node-parts-with-cache (node)
  (or (gethash node *node-parts-cache*)
      (let ((parts (node-parts node)))
        (setf (gethash node *node-parts-cache*)
              (list* :bindings ()
                     :initialize ()
                     :update ()
                     :finalize ()
                     (ecase (io-channels node)
                       (1 `(:sample-1 ,(getf parts :sample-1)))
                       (2 `(:sample-1 ,(getf parts :sample-1)
                            :sample-2 ,(getf parts :sample-2))))))
        parts)))

(defvar *buffer-pointer*)

(defmacro with-node-parts ((bindings initialize update sample-1 sample-2 finalize)
                           node &body body)
  `(let* ((parts (node-parts-with-cache ,node))
          (,bindings (getf parts :bindings))
          (,initialize (getf parts :initialize))
          (,update (getf parts :update))
          (,sample-1 (getf parts :sample-1))
          (,sample-2 (getf parts :sample-2))
          (,finalize (getf parts :finalize)))
     ,@body))

(defun input-parts (input)
  (let ((bindings ())
        (initialize ())
        (update ())
        (sample-1 (list (input-default-sample-1 input)))
        (sample-2 (list (input-default-sample-2 input)))
        (finalize ()))
    (loop
      for output in (io-nodes input)
      for parts = (node-parts-with-cache output)
      do (setf bindings (append (getf parts :bindings) bindings)
               initialize (append (getf parts :initialize) initialize)
               update (append (getf parts :update) update)
               finalize (append (getf parts :finalize) finalize))
         (push (getf parts :sample-1) sample-1)
         (push (getf parts :sample-2) sample-2))
    `(:bindings ,bindings
      :initialize ,initialize
      :update ,update
      :sample-1 (+ ,@sample-1)
      :sample-2 (+ ,@sample-2)
      :finalize ,finalize)))

(defmacro with-input-parts ((bindings initialize update sample-1 sample-2 finalize)
                            input &body body)
  `(let* ((parts (input-parts ,input))
          (,bindings (getf parts :bindings))
          (,initialize (getf parts :initialize))
          (,update (getf parts :update))
          (,sample-1 (getf parts :sample-1))
          (,sample-2 (getf parts :sample-2))
          (,finalize (getf parts :finalize)))
     ,@body))

(defun render-body (buffer input)
  (let ((channels (io-channels input)))
    (with-node-parts-cache
        (with-input-parts (bindings initialize update sample-1 sample-2 finalize) input
          `(let* ((*current-time* *current-time*)
                  (dtime (/ 1 *sampling-rate*))
                  ,@bindings)
             ,@initialize
             (loop
               for *buffer-pointer* from 0 below *buffer-size*
               do ,@update
                  ,(ecase channels
                     (1 `(setf (aref ,buffer 0 *buffer-pointer*) ,sample-1))
                     (2 `(setf (aref ,buffer 0 *buffer-pointer*) ,sample-1
                               (aref ,buffer 1 *buffer-pointer*) ,sample-2)))
                  (incf *current-time* dtime))
             ,@finalize)))))

(defun build-render (input)
  (with-gensyms (buffer)
    (coerce `(lambda (,buffer)
               ,(render-body buffer input)
               (values))
            'function)))
