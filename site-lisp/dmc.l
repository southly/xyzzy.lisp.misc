;;; dmc.l
;;;
;;;     C/C++とかJavaとかのメンバをdabbrevライクに補完。
;;;
;;; Copyright (c) 2006 NANRI
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

(provide "dmc")

(in-package "editor")

(export '(dmc-popup))

(defun dmc-instance-name ()
  (save-excursion
    (let ((start (progn (skip-syntax-spec-backward "w_") (point))))
      (cond
       ((char= #\. (char-before start))
        (buffer-substring (progn (forward-char -1) (skip-syntax-spec-backward "w_") (point)) (1- start)))
       ((and (char= #\> (char-before start))
             (char= #\- (char-before (1- start))))
        (buffer-substring (progn (forward-char -2) (skip-syntax-spec-backward "w_") (point)) (- start 2)))
       (t
        nil)))))

(defun dmc-find-all-candidates (name abbrev case-fold match-table start matches)
  (let ((regexp (compile-regexp (concat (regexp-quote name) "\\(\\.\\|->\\)")))
        (f (if *dabbrevs-case-fold* #'string-equal #'string=)))
    (save-excursion
      (goto-char (point-min))
      (while (scan-buffer regexp :case-fold case-fold
                          :tail t :left-bound :symbol :regexp t)
        (let ((from (point))
              (text (buffer-substring (point) (save-excursion (skip-syntax-spec-forward "w_") (point)))))
          (unless (or (zerop (length text))
                      (gethash text match-table)
                      (> (length abbrev) (length text))
                      (and abbrev (not (funcall f abbrev text :end2 (length abbrev)))))
            (setf (gethash text match-table) from)
            (push text matches))))
      matches)))

(defun dmc-popup ()
  (interactive "*")
  (let ((end (point))
        (start (save-excursion (skip-syntax-spec-backward "w_") (point)))
        (name (dmc-instance-name)))
    (unless name
      (return-from dmc-popup nil))
    (let ((match-table (make-hash-table :test (if *dabbrevs-case-fold* #'equalp #'equal)))
          matches abbrev)
      (when (/= start end)
        (setq abbrev (buffer-substring start end))
        (setf (gethash abbrev match-table) start))
      (setq matches (dmc-find-all-candidates name abbrev *dabbrevs-case-fold* match-table start nil))
      (unless *dabbrev-popup-this-buffer-only*
        (let ((curbuf (selected-buffer))
              (case-fold *dabbrevs-case-fold*)
              (syntax-table (syntax-table)))
          (with-set-buffer
            (with-interval-message (300)
              (save-excursion
                (dolist (buffer (buffer-list))
                  (unless (eq buffer curbuf)
                    (message "Searching (~A)..." (buffer-name buffer))
                    (set-buffer buffer)
                    (save-excursion
                      (let ((osyntax-table (syntax-table)))
                        (unwind-protect
                            (progn
                              (use-syntax-table syntax-table nil t)
                              (setq matches (dmc-find-all-candidates
                                             name abbrev case-fold match-table nil matches)))
                          (use-syntax-table osyntax-table nil t))))))))))
        (clear-message))
      (if matches
          (popup-completion-list-loop (sort matches #'string-lessp) start end)
        (plain-error "ないよん")))))

(defun popup-list-loop-2 (list callback &optional point with-insert (base ""))
  (let ((add "") (matched list) matched1 selected input str)
    (loop
      (if with-insert (insert add))
      (popup-list matched (lambda (x) (setq selected x)) point) ; #\ESC
      (refresh-screen)
      (while (not (or selected (setq input (read-char-no-hang *keyboard*))))
        (do-events))
      (if with-insert (delete-region (- (point) (length add)) (point)))
      (cond (selected
             (funcall callback selected)
             (if (eq input #\SPC) (unread-char input))
             (return t))
;           ((eq input #\ESC) (return nil))
            ((eq input #\C-h) (unless (zerop (length add)) (setq add (substring add 0 -1))))
            ((graphic-char-p input) (setq add (format nil "~A~C" add input)))
            (t (unread-char input) (return nil)))
      (setq str (concat base add))
      (setq matched1 (remove-if (lambda (x)
                                  (or (< (length x) (length str))
                                      (string/= x str :end1 (length str))))
                                list))
      (if (endp matched1) (if with-insert
                              (progn (funcall callback str) (return t))
                            (setq add (substring add 0 -1)))
        (setq matched matched1)))))

(defun popup-completion-list-loop (list from &optional (to from))
  (let ((buffer (selected-buffer))
        (point (point)))
    (popup-list-loop-2 list #'(lambda (string)
                                (when (and (eq buffer (selected-buffer))
                                           (= point (point)))
                                  (let ((l (- to from)))
                                    (when (and (>= (length string) l)
                                               (save-excursion
                                                 (goto-char from)
                                                 (looking-for (subseq string 0 l))))
                                      (incf from l)
                                      (setq string (subseq string l))))
                                  (delete-region from to)
                                  (insert string)
                                  (refresh-screen)))
                       from
                       t
                       (buffer-substring from to))
    ))
