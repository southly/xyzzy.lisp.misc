;;;;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; $Id$
;;;     delete ifdef
;;;
;;; * 使用法
;;;   ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下を記述します。
;;;
;;; * 依存
;;;
;;; * 履歴
;;; 
;;; * ライセンス
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
(provide "deleteif")

(require "hideif")

(in-package "editor")

(export '(delete-ifdef))

(defun delete-ifdef ()
  (interactive)
  (long-operation
    (let ((obuffer (selected-buffer))
          buffer)
      (save-restriction
        (widen)
        (unwind-protect
            (let (range)
              (save-excursion
                (setq buffer (create-new-buffer "*hide ifdef*"))
                (set-buffer buffer)
                (use-syntax-table (syntax-table obuffer))
                (set-default-directory (default-directory obuffer))
                (insert-buffer-substring obuffer)
                (hide-ifdef-mark-directive)
                (hide-ifdef-run-cpp obuffer)
                (goto-char (point-min))
                (while (scan-buffer "^!!!\\([0-9]+\\)-\\([0-9]+\\)!!!\015?$"
                                    :regexp t :tail t)
                  (push (cons (parse-integer (match-string 1))
                              (parse-integer (match-string 2)))
                        range)))
              (let ((last (caar range)))
                (mapc #'(lambda (x)
                          (delete-region (cdr x) last)
                          (setq last (car x)))
                      (cdr range))))
          (when buffer
            (delete-buffer buffer)))))))
