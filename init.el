
;; comment test

;; settings and general behavior
(setq inhibit-startup-message t)        ; start with a blank screen
(setq require-final-newline 'askme)	; when saving files ...
(setq mode-require-final-newline 'askme); when saving files ...
(show-paren-mode 1)                     ; highlight matching paren
(tool-bar-mode -1)                      ; turn off toolbar

(require 'xcscope "xcscope" t)          ; ignore errors

;; Redefine this standard emacs function to not save anything in the kill ring.
;; This affects M-d, M-delete, C-delete (kill-word), C-backspace (backward-k-w)
(defun my-kill-word (arg)
  "Delete characters forward until encountering the end of a word.
With argument, do this that many times.  Do not save in kill ring."
  (interactive "p")
  (delete-char (- (point) (progn (forward-word arg) (point)))))
(defalias 'kill-word 'my-kill-word)	; Rebind kill-word to my-kill-word

;; Use ^z as a prefix key, for invoking useful functions easily:
(global-unset-key "\C-z")
(global-set-key "\C-z\C-b" 'insert-buffer)
(global-set-key "\C-z\C-c" 'compare-windows)
(global-set-key "\C-z\C-d" 'duplicate-window)
(global-set-key "\C-z\C-h" 'mark-defun)	; ESC C-h now works only for XWindows
(global-set-key "\C-z\C-i" 'ispell-buffer)
(global-set-key "\C-z\C-q" 'toggle-read-only)


;;	Section 3. Mode line format and optional features.
;; This rearranges and reformats your mode line, and changes the name of
;; buffers which hold files to be the file name, a space, and the file's path.
(setq mode-line-modified '("-%1+"))
(setq default-mode-line-format
      (list "" 'mode-line-modified "%Z" '(line-number-mode "L%l ")
	    '(column-number-mode "C%c ") '(-3 . "%p") "-"
	    'mode-line-buffer-identification "  " 'global-mode-string
	    " %[(" 'mode-name 'minor-mode-alist "%n" 'mode-line-process
	    ")%]-%-"))

(setq line-number-mode t)		; display the current line number
(setq column-number-mode t)		; display the current column num
(display-time)                          ; display the current time

;;	Section 4. Major modes

(setq c-style-variables-are-local-p t)
(setq default-major-mode 'text-mode)	; 20.2 was indented-text-mode
(setq colon-double-space t)		; fill keeps two spaces after co
(add-hook 'after-save-hook              ; usefule when creating scripts
  'executable-make-buffer-file-executable-if-script-p)

;; cc-mode:  customization, etc.
;; cc-mode is an alternative to the old c-mode and c++-mode, combining the two,
;; with many 'improvements'.  It has become the FSF default as of 19.30, and
;; starting either c-mode or c++-mode actually runs cc-mode instead.
;; Puts {} under the first letter of the if/for/do, and indents 4 spaces.
;; This is approximately "BSD" style; see the file
;;   /usr/share/emacs/*/lisp/progmodes/cc-mode.el for further information.
(add-hook 'c-mode-common-hook 'cc-hook)
(defun cc-hook ()
  (c-set-style "stroustrup")		; as modified below
  ;;(setq c-basic-offset 4)		; indent 4 spaces
  (setq c-tab-always-indent 'literals)	; insert tabs in literals; always indent
  (setq comment-column 40)		; 40 is the emacs default
  (setq fill-column 78)
  (setq c-recognize-knr-p nil))		; we use only ANSI prototypes

;; How to format C/C++ comments:
(defun my-comment-fill-feature ()
  (make-local-variable 'adaptive-fill-mode)
  (make-local-variable 'adaptive-fill-regexp)
  (make-local-variable 'paragraph-ignore-fill-prefix)
  (setq adaptive-fill-mode t)
  (setq adaptive-fill-regexp "[ \t]*\\([#;>/*!]+ +\\)?")
  (setq paragraph-separate "[ \t\f/*!]*$")
  ;; '/*' anywhere in a line starts a new paragraph
  (setq paragraph-start (concat ".*/\\*!?\\|" paragraph-separate))
  ;;;;(setq paragraph-ignore-fill-prefix nil)
  )
;; These hooks also get run by cc-mode
(defun my-c++-mode-hook ()
  (modify-syntax-entry ?_ "w")		; make "_" a word constituent
  (my-comment-fill-feature)
  (setq indent-tabs-mode nil)		
  (c-set-offset 'innamespace nil)	; don't indent namespace bodies
  )
(add-hook 'c++-mode-hook 'my-c++-mode-hook)
(defun my-c-mode-hook ()
  (modify-syntax-entry ?_ "w")		; make "_" a word constituent
  (my-comment-fill-feature)
  (setq comment-start "// ")
  (setq comment-end "")
  (setq indent-tabs-mode nil)
  )
(add-hook 'c-mode-hook 'my-c-mode-hook)


;;	Section 5. X-windows features and function-key assignments.
(if window-system
    (progn
      
      (setq font-lock-maximum-decoration t) ; use lots of colors
      (setq font-lock-maximum-size 100000)
      (if (fboundp 'global-font-lock-mode)
	  (global-font-lock-mode t)	; new in 19.31
	(defun turn-on-font-lock () (font-lock-mode 1)) ; standard in 19.29
	(add-hook 'find-file-hooks 'turn-on-font-lock 'append))
      (condition-case error		; handle undefined colors
	  (progn
	    ;;(set-foreground-color "ivory")
	    ;;(set-background-color "black")
	    (set-cursor-color "magenta")       ; a dark but eye-catching color
	    (setq default-frame-alist
		  (nconc default-frame-alist
			 '((cursor-color . "magenta"))))
	    (make-face 'font-lock-string-face) ; a darker color
	    (set-face-foreground 'font-lock-string-face "sienna"))
	(error (message "%s" (cdr error))))
      (if (fboundp 'font-lock-add-keywords) ; highlite $symbols for cvp
	  (font-lock-add-keywords 'c++-mode '(("\\$[a-zA-Z0-9_]+" 0 
					       font-lock-builtin-face t))))

      ;; sometimes needed to be able to copy from emacs to other windows
      (global-set-key "\C-w" 'clipboard-kill-region)
      (global-set-key "\M-w" 'clipboard-kill-ring-save)
      (global-set-key "\C-y" 'clipboard-yank)

      ;; run the "man" command in a separate frame of a specified size
      (setq Man-notify-method 'newframe)
      (setq man-width (or (getenv "MANWIDTH") "80"))
      (setenv "MANWIDTH" man-width)
      (setq Man-frame-parameters
	    (list (cons 'width (+ (string-to-number man-width) 3))
		  '(height . 40)))

      )
  ;; if not Xwindows ---

)

(desktop-load-default)			; load the defaults
(desktop-read)				; restore the desktop if 
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(show-paren-mode t))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "white" :foreground "black" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 98 :width normal :foundry "unknown" :family "DejaVu Sans Mono")))))



(defun duplicate-window ()
  "Make the next window a duplicate of the current window."
  (interactive)
  (switch-to-buffer-other-window (current-buffer)) )

;; create a backup file directory
(defun make-backup-file-name (file)
(concat “~/.emacs_backups/” (file-name-nondirectory file) “~”))
