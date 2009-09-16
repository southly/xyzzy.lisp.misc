;;;;;; -*- Mode: Lisp; -*-
;;;
;;; $Id$
;;;     time
;;;
;;; * 使用法
;;;   ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下を記述します。
;;;
;;; * 依存
;;;
;;; * 履歴
;;; 
;;; * ライセンス
;;; Copyright (c) 2009 NANRI <southly@gmail.com>
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
(in-package "user")

(export '(time))

(defmacro time (form)
  `(%time (lambda () ,form)))

(defun %time (f)
  (let (old-time new-time old-counter new-counter)
    (setf old-time (get-internal-real-time)
	  old-counter (si:performance-counter))
    (funcall f)
    (setf new-time (get-internal-real-time)
	  new-counter (si:performance-counter))
    (format t "get-internal-real-time : ~F ms~%   performance-counter : ~F ms~%"
	    (/ (- new-time old-time) internal-time-units-per-second 0.001d0)
	    (/ (- new-counter old-counter) si:*performance-counter-frequency* 0.001d0)))
  (values))
