;;;;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; $Id$
;;;     reopen
;;;
;;; * �g�p�@
;;;   ~/.xyzzy �܂��� $XYZZY/site-lisp/siteinit.l �Ɉȉ����L�q���܂��B
;;;
;;; * �ˑ�
;;;
;;; * ����
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
(in-package "editor")

(export '(reopen-file))

(defun reopen-file (filename &optional encoding nomsg)
  (interactive "fReopen file:  \n0zEncoding: " :title0 "Reopen file")
  (let ((*expected-fileio-encoding* (or encoding *expected-fileio-encoding*)))
    (declare (special *expected-fileio-encoding*))
    (when buffer-read-only
      (error "�������݋֎~�o�b�t�@�ł�"))
    (setq filename (namestring filename))
    (when (special-file-p filename)
      (error "~a�̓f�o�C�X�t�@�C���ł�" filename))
    (when (file-directory-p filename)
      (error "~a�̓f�B���N�g���ł�" filename))
    (unless (and (valid-path-p filename)
                 (file-exist-p filename))
      (error "~a\n�t�@�C���܂��̓f�B���N�g����������܂���" filename))
    (when (and (need-buffer-save-p (selected-buffer))
               (not (no-or-yes-p "�o�b�t�@���ύX����Ă��܂��B�ύX���e��j�����܂���?")))
      (return-from reopen-file nil))
    (widen)
    (delete-region 0 (buffer-size))
    (or nomsg
        (message "Reading file..."))
    (multiple-value-bind (nlines noerror)
        (insert-file-contents filename)
      (unless noerror
        (warn "~a\n������������Ȃ��Ă��ׂēǂݍ��߂܂���ł���" filename)
        (set-buffer-truncated-p t))
      (set-buffer-modified-p nil)
      (update-visited-file-modtime)
      (or nomsg
          (message "~d�s�ǂݍ��݂܂���" nlines))
      nlines)))

(defun revert-buffer-reopen ()
  (let ((opoint (point)))
    (or (file-visited-p)
        (error "�t�@�C����������܂���B"))
    (when (let ((buffer-read-only nil))
            (declare (special buffer-read-only))
            (let* ((filename (get-buffer-file-name))
                   (nlines (reopen-file filename)))
              (find-file-lock-file)
              (find-file-notice filename nlines nil))
            buffer-read-only)
      (setq buffer-read-only t))
    (goto-char opoint)))        ;

(setq-default verify-visited-file-modtime :auto)
(setq-default revert-buffer-function #'revert-buffer-reopen)

; from $XYZZY/lisp/buffer.l
(defun verify-buffers-file-modtime ()
  (let ((no-query nil))
    (with-set-buffer
      (dolist (buffer (buffer-list) t)
        (or (null (get-buffer-file-name buffer))
            (null (buffer-local-value buffer 'verify-visited-file-modtime))
            (verify-visited-file-modtime buffer)
            (let ((b (selected-buffer))
                  (p (point)))
              (set-buffer buffer)
              (when (cond ((eq no-query :yes) t)
                          ((eq no-query :no) nil)
                          ((eq verify-visited-file-modtime ':auto) t)
                          (t
                           (refresh-screen)
                           (case (message-box
                                  (format nil "~A\n\n�N��������Ƀt�@�C����ύX���Ă��܂��B�f�B�X�N����ǂݒ����܂���?"
                                          (get-buffer-file-name buffer))
                                  nil '(:yes-no-cancel :question :button1)
                                  :button4 "��������������(&A)")
                             (:yes t)
                             (:no nil)
                             (:button4 (setq no-query :yes) t)
                             (t (setq no-query :no) nil))))
                (update-visited-file-modtime)
                (revert-buffer))
              (set-buffer b)
              (goto-char p)))))))