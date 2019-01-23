(defpackage corn.extra.voice-manager
  (:use :cl)
  (:export :voice-manager
           :create-voice-manager
           :voice-manager-noteon
           :voice-manager-noteoff))
(in-package :corn.extra.voice-manager)

(defstruct voice
  node
  (id nil)
  (noteon-time 0)
  (noteoff-time 0))

(defstruct voice-manager
  voices
  noteon-fn
  noteoff-fn)

(defun create-voice-manager (&key nodes noteon noteoff)
  (make-voice-manager :voices (mapcar (lambda (node) (make-voice :node node)) nodes)
                      :noteon-fn noteon
                      :noteoff-fn noteoff))

(defun voice-manager-select (voice-manager)
  (or (loop
        with voices = (or (remove-if #'voice-id
                                     (voice-manager-voices voice-manager))
                          (return))
        with selected-voice = (first voices)
        for voice in (cdr voices)
        if (< (voice-noteoff-time voice)
              (voice-noteoff-time selected-voice))
        do (setf selected-voice voice)
        finally (return selected-voice))
      (loop
        with voices = (voice-manager-voices voice-manager)
        with selected-voice = (first voices)
        for voice in (cdr voices)
                     if (< (voice-noteon-time voice)
                           (voice-noteon-time selected-voice))
        do (setf selected-voice voice)
        finally (return selected-voice))))

(defun voice-manager-noteon (voice-manager id time &rest rest)
  (let ((voice (voice-manager-select voice-manager)))
    (apply (voice-manager-noteon-fn voice-manager) (voice-node voice) time rest)
    (setf (voice-id voice) id
          (voice-noteon-time voice) time)))

(defun voice-manager-noteoff (voice-manager id time &rest rest)
  (let ((voice (find id (voice-manager-voices voice-manager) :key #'voice-id)))
    (apply (voice-manager-noteoff-fn voice-manager) (voice-node voice) time rest)
    (setf (voice-id voice) nil
          (voice-noteoff-time voice) time)))
