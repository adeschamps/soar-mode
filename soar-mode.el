;;; soar-mode.el --- A major mode for the Soar language

;; Version: 0.1
;; Keywords: languages, soar
;; URL: https://github.com/adeschamps/soar-mode
;; License: BSD-3-Clause

;;; Commentary:

;; This package provides syntax highlighting and indentation for the
;; Soar language (https://soar.eecs.umich.edu/).

;;; Code:

(defvar soar-mode-hook nil)

(defvar soar-mode-map
  (let ((map (make-keymap)))
    (define-key map "\C-j" 'newline-and-indent)
    map)
  "Keymap for Soar major mode.")

(defconst soar-mode-font-lock-keywords
  "\\b\\(source\\|sp\\|state\\)\\b")

(defconst soar-font-lock-keywords
  (list
   '("\\$[^ \.]+"                     . font-lock-preprocessor-face)  ;; $OUTPUT-LINK
   (list soar-mode-font-lock-keywords 1 font-lock-keyword-face)       ;; keywords
   '("#[^\n]*"                        . font-lock-comment-face)       ;; # comment
   '("\\^[^ ]+"                       . font-lock-variable-name-face) ;; ^this.that
   '("<[^>]+>"                        . font-lock-constant-face)      ;; <s>
   '("\\[ *\\([^ ]+\\)"               1 font-lock-function-name-face) ;; [ngs-tag ... ]
   )
  "Highlighting expressions for Soar mode.")

(defvar soar-font-lock-keywords soar-font-lock-keywords-1
  "Highlighting for Soar mode.")

(defun soar-indent-line ()
  "Indent current line as Soar code."
  (interactive)
  (save-excursion
    (back-to-indentation)
    (indent-line-to
     (cond
      ((bobp)             0)
      ((looking-at "sp")  0)
      ((looking-at "-->") 0)
      ((looking-at "\(")  default-tab-width)
      ((looking-at "\\[") default-tab-width)
      ((looking-at "-?\\^") (- (save-excursion (forward-line -1) (beginning-of-line)
                                               (if (looking-at "^[^^]+\\(\\^\\)")
                                                   (- (match-beginning 1) (match-beginning 0)) 0))
                               (if (looking-at "-") 1 0)))
      (t 0))))
  (if (bolp) (back-to-indentation)))

(defun soar-blank-line-p ()
  "Predicate to test whether a line is empty."
  (= (current-indentation)
     (- (line-end-position) (line-beginning-position))))

(defun soar-indent-line-2 ()
  "Indent current line of Soar code."
  (interactive)
  (save-excursion
    ;; Set cur-indent to the indentation of the previous line.
    (save-excursion
      ;; Go to the last non-empty line
      (while (progn (forward-line -1) (soar-blank-line-p)))
      (back-to-indentation)
      (defvar soar-mode-cur-indent (current-indentation))
      ;; If the first character was a '-', then soar-mode-cur-indent should be one larger
      (if (looking-at "-") (setf soar-mode-cur-indent (1+ soar-mode-cur-indent)))
      (if (looking-at "sp") (setf soar-mode-cur-indent default-tab-width))
      (if (looking-at "\"") (setf soar-mode-cur-indent 0))

      (end-of-line)
      (if (looking-back "[({[]" nil) (setf soar-mode-cur-indent (+ soar-mode-cur-indent default-tab-width))))

    (end-of-line)
    (if (looking-back "[)}\]]" nil) (setf soar-mode-cur-indent (- soar-mode-cur-indent default-tab-width)))

    (indent-line-to soar-mode-cur-indent))
  (if (bolp) (back-to-indentation)))


(define-derived-mode soar-mode fundamental-mode "Soar"
  "Major mode for editing Soar files"
  (set (make-local-variable 'font-lock-defaults) '(soar-font-lock-keywords))
  (set (make-local-variable 'indent-line-function) 'soar-indent-line)
  (setq font-lock-keywords-only t)
  (set 'default-tab-width 4))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.soar\\'" . soar-mode))

(provide 'soar-mode)
;;; soar-mode.el ends here
