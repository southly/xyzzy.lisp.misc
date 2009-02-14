;;;;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; $Id: trace.l 321 2008-03-14 03:41:36Z raido $
;;;     trace macro
;;;
;;; * �g�p�@
;;;   ~/.xyzzy �܂��� $XYZZY/site-lisp/siteinit.l �Ɉȉ����L�q���܂��B
;;;
;;; * �ˑ�
;;;
;;; * ����
;;;   - �쐬��
;;;
;;; * TODO
;;;   - trace �}�N���Ŏg�p���Ă���֐��� trace ���ꂽ�Ƃ��̑Ή����l����
;;;   - macro �� trace �̈����ɂ��čl����
;;;   - �o�͂ɂ��čl����
;;;   - ���̑�
;;;
;;; * ���C�Z���X
;;; Copyright (c) 2008 NANRI <southly@gmail.com>
;;; 
;;; Permission is hereby granted, free of charge, to any person obtaining a 
;;; copy of this software and associated documentation files (the "Software"), 
;;; to deal in the Software without restriction, including without 
;;; limitation the rights to use, copy, modify, merge, publish, distribute, 
;;; sublicense, and/or sell copies of the Software, and to permit persons to 
;;; whom the Software is furnished to do so, subject to the following 
;;; conditions:
;;; 
;;; The above copyright notice and this permission notice shall be included 
;;; in all copies or substantial portions of the Software.
;;; 
;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
;;; OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
;;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
;;; IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
;;; CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
;;; TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
;;; SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
;;;

(provide "trace")

(defvar *trace-functions* nil)
(unless *trace-functions*
  (setq *trace-functions* (make-hash-table)))

(defvar *trace-output* nil)

(defun get-trace-stream ()
  (cond ((eq *this-command* 'ed::eval-print-last-sexp)
         *standard-output*)
        ((and (buffer-stream-p *trace-output*)
              (ignore-errors (buffer-stream-buffer *trace-output*)))
         *trace-output*)
        (t
         (let ((buffer (get-buffer-create "*Trace*")))
           (setup-temp-buffer buffer)
           (setq *trace-output* (make-buffer-stream buffer))))))

(defmacro trace (&rest function-name)
  `(progn ,@(mapcar #'(lambda (x) `(trace-1 ,x)) function-name) ',function-name))

(defmacro untrace (&rest function-name)
  (let ((f (or function-name
               (let ((l nil)) (maphash #'(lambda (x y) (push x l)) *trace-functions*) l))))
    `(progn ,@(mapcar #'(lambda (x) `(untrace-1 ,x)) f) ',f)))

(defmacro trace-1 (sym)
  (let* ((fn (symbol-function sym))
         (r (gensym)))
    `(unless (or (gethash ',sym *trace-functions*)
                 (not (functionp ,fn)))
       (setf (gethash ',sym *trace-functions*) ,fn)
       (setf (symbol-function ',sym)
             #'(lambda (&rest args)
                 (format (get-trace-stream) "> (~s~{ ~s~})~%" ',sym args)
                 (let ((,r (multiple-value-list (apply ,fn args))))
                   (format (get-trace-stream) "< ~s ==> ~{~s~^ ~}~%" ',sym ,r)
                   (values-list ,r)))))))

(defmacro untrace-1 (sym)
  `(when (gethash ',sym *trace-functions*)
     (setf (symbol-function ',sym) (gethash ',sym *trace-functions*))
     (remhash ',sym *trace-functions*)))