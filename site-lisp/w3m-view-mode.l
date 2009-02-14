;;;;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; $Id$
;;;     w3m view-mode
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
(provide "w3m-view-mode")

(in-package "editor")

(export '(w3m-view-mode *w3m-view-mode-map* *w3m-view-mode-hook*))

(defvar *w3m-view-mode-hook* nil)
(defvar *w3m-view-mode-window-flags* (+ *window-flag-eof*
                                        *window-flag-full-width-space*
                                        *window-flag-half-width-space*
                                        *window-flag-line-number*
                                        *window-flag-newline*
                                        *window-flag-tab*))

(defvar-local @w3m-view-mode nil)
(defvar *w3m-view-mode-map* nil)
(unless *w3m-view-mode-map*
  (setq *w3m-view-mode-map* (make-sparse-keymap))
  (define-key *w3m-view-mode-map* #\C-v 'next-page)
  (define-key *w3m-view-mode-map* #\SPC 'next-page)
  (define-key *w3m-view-mode-map* #\+   'next-page)
  (define-key *w3m-view-mode-map* #\M-v 'previous-page)
  (define-key *w3m-view-mode-map* #\b 'previous-page)
  (define-key *w3m-view-mode-map* #\- 'previous-page)
  (define-key *w3m-view-mode-map* #\h 'backward-char)
  (define-key *w3m-view-mode-map* #\C-b 'backward-char)
  (define-key *w3m-view-mode-map* #\j 'next-line)
  (define-key *w3m-view-mode-map* #\C-n 'next-line)
  (define-key *w3m-view-mode-map* #\k 'previous-line)
  (define-key *w3m-view-mode-map* #\C-p 'previous-line)
  (define-key *w3m-view-mode-map* #\l 'forward-char)
  (define-key *w3m-view-mode-map* #\C-f 'forward-char)
  (define-key *w3m-view-mode-map* #\> 'scroll-right)
  (define-key *w3m-view-mode-map* #\. 'scroll-right)
  (define-key *w3m-view-mode-map* #\< 'scroll-left)
  (define-key *w3m-view-mode-map* #\, 'scroll-left)
  (define-key *w3m-view-mode-map* #\C-a 'beginning-of-line)
  (define-key *w3m-view-mode-map* #\^ 'beginning-of-line)
  (define-key *w3m-view-mode-map* #\C-e 'end-of-line)
  (define-key *w3m-view-mode-map* #\$ 'end-of-line)
  (define-key *w3m-view-mode-map* #\z 'recenter)
  (define-key *w3m-view-mode-map* #\M-g 'goto-line)
  (define-key *w3m-view-mode-map* #\g 'beginning-of-buffer)
  (define-key *w3m-view-mode-map* #\M-< 'beginning-of-buffer)
  (define-key *w3m-view-mode-map* #\G 'end-of-buffer)
  (define-key *w3m-view-mode-map* #\M-> 'end-of-buffer)
  (define-key *w3m-view-mode-map* #\w 'forward-word)
  (define-key *w3m-view-mode-map* #\W 'previous-word)
  (define-key *w3m-view-mode-map* #\/ 'search-forward)
  (define-key *w3m-view-mode-map* #\? 'search-backward)
  (define-key *w3m-view-mode-map* #\n 'repeat-forward-search)
  (define-key *w3m-view-mode-map* #\N 'repeat-backward-search)
  )

(defun w3m-view-mode (&optional (arg nil sv))
  (interactive "p")
  (toggle-mode '@w3m-view-mode arg sv)
  (update-mode-line t)
  (make-local-variable 'w3m-view-property)
  (cond (@w3m-view-mode
         (setq w3m-view-property (list buffer-read-only (multiple-value-list (get-local-window-flags (selected-buffer)))))
         (toggle-read-only @w3m-view-mode)
         (set-minor-mode-map *w3m-view-mode-map*)
         (set-local-window-flags (selected-buffer) *w3m-view-mode-window-flags* nil))
        (t
         (toggle-read-only (car w3m-view-property))
         (unset-minor-mode-map *w3m-view-mode-map*)
         (set-local-window-flags (selected-buffer) *w3m-view-mode-window-flags* :default)
         (set-local-window-flags (selected-buffer) (caadr w3m-view-property) t)
         (set-local-window-flags (selected-buffer) (cadadr w3m-view-property) nil)))
  (if *w3m-view-mode-hook* (funcall *w3m-view-mode-hook* @w3m-view-mode))
  t)

(pushnew '(@w3m-view-mode . "w3m-view") *minor-mode-alist* :key #'car)

(global-set-key '(#\C-x #\C-q) 'w3m-view-mode)
