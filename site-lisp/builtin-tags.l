;;;;;; -*- Mode: Lisp -*-
;;;
;;; $Id$
;;;     builtin.l から xyzzy の C++ の実装にジャンプします。
;;;
;;; * 謝辞
;;;    *lisp->c-mapping* と make-c-name は MIYAMUKO さんの xyscope.l からいただきました。
;;;    また、その他いろいろ参考にさせていただきました。
;;;    http://coderepos.org/share/browser/lang/xyzzy/xyscope/site-lisp/xyscope.l
;;;    xyscope.l ライセンス
;;;    ;; Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;    ;;
;;;    ;; Author: MIYAMUKO Katsuyuki <miyamuko@gmail.com>
;;;    ;; Version: 0.1
;;;    ;; Keywords: development
;;;    ;;
;;;    ;; Permission is hereby granted, free of charge, to any person obtaining
;;;    ;; a copy of this software and associated documentation files (the
;;;    ;; "Software"), to deal in the Software without restriction, including
;;;    ;; without limitation the rights to use, copy, modify, merge, publish,
;;;    ;; distribute, sublicense, and/or sell copies of the Software, and to
;;;    ;; permit persons to whom the Software is furnished to do so, subject to
;;;    ;; the following conditions:
;;;    ;;
;;;    ;; The above copyright notice and this permission notice shall be
;;;    ;; included in all copies or substantial portions of the Software.
;;;    ;;
;;;    ;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;;;    ;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;;;    ;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;;;    ;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
;;;    ;; LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
;;;    ;; OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
;;;    ;; WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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

(defvar *xyzzy-source-directory*
  (merge-pathnames "xyzzy-src" (si:system-root))
  "xyzzy のソースの XTAGS ファイルがあるディレクトリ")

(defparameter *lisp->c-mapping*
  '(;; DEFUN2
    (list* . "list_star")
    (string= . "string_equal")
    (string-equal . "string_equalp")
    (string/= . "string_not_equal")
    (string-not-equal . "string_not_equalp")
    (string< . "string_less")
    (string> . "string_greater")
    (string<= . "string_not_greater")
    (string>= . "string_not_less")
    (= . "number_eql")
    (/= . "number_not_eql")
    (< . "number_less")
    (> . "number_greater")
    (<= . "number_not_greater")
    (>= . "number_not_less")
    (+ . "add")
    (- . "subtract")
    (* . "multiply")
    (/ . "divide")
    (char= . "char_eql")
    (char/= . "char_not_eql")
    (char< . "char_less")
    (char> . "char_greater")
    (char<= . "char_not_greater")
    (char>= . "char_not_less")
    (set-syntax-end-c++-comment . "set-syntax-end-cplusplus-comment")
    (set-syntax-start-c++-comment . "set-syntax-start-cplusplus-comment")
    (syntax-end-c++-comment-p . "syntax-end-cplusplus-comment-p")
    (syntax-c++-comment-p . "syntax-cplusplus-comment-p")
    ;; DEFVAR
    (*ime-does-not-process-C-\\* . "ime_does_not_process_control_backslach")
    (*enable-D&D-edit* . "enable_DnD_edit")
    ))

(defun make-c-name (prefix sym)
  (let ((str (or (cdr (assoc sym *lisp->c-mapping*))
                 (symbol-name sym))))
    (concat prefix (remove #\* (substitute #\_ #\- str)))))

(defun systemp (sym)
  (and (find-symbol (symbol-name sym) "system") (not (find-symbol (symbol-name sym) "lisp"))))

(defun builtin-lisp-tags-find-target ()
  (let* ((opoint (point))
         (line (read-from-string (buffer-substring (progn (goto-bol) (point)) (progn (goto-eol) (point)))))
         (sym (if (eq (first line) 'si::defun-builtin) (second line) nil)))
    (goto-char opoint)
    (values nil (if sym (make-c-name (if (systemp sym) "Fsi_" "F") sym) "") t)))

(defun builtin-lisp-tags-hook ()
  (and (get-buffer-file-name)
       (check-valid-pathname *xyzzy-source-directory*)
       (path-equal (get-buffer-file-name) (merge-pathnames "lisp/builtin.l" (si:system-root)))
       (progn
         (set-default-directory *xyzzy-source-directory*)
         (setq tags-find-target #'builtin-lisp-tags-find-target))))

(add-hook '*lisp-mode-hook* 'builtin-lisp-tags-hook)
