(use-package :split-sequence)
(in-package :lem-user)

(load-theme "emacs-dark")

;;; Setup Paredit
(lem:add-hook lem:*find-file-hook*
              (lambda (buffer)
                (when (eq (buffer-major-mode buffer) 'lem-lisp-mode:lisp-mode)
                  (change-buffer-mode buffer 'lem-paredit-mode:paredit-mode t))))

;; Make undo and redo what I am used to
(define-key *global-keymap* "C-_" 'undo)
(define-key *global-keymap* "C-\\" 'redo)

;; Paredit Mappings
(define-key lem-paredit-mode:*paredit-mode-keymap* "Shift-Right"
  'lem-paredit-mode:paredit-slurp)
(define-key lem-paredit-mode:*paredit-mode-keymap* "Shift-Left"
  'lem-paredit-mode:paredit-barf)
(lem:define-command paredit-quote-wrap () ()
  (progn 
    (lem-paredit-mode:paredit-insert-doublequote)
    (lem-paredit-mode:paredit-slurp)
    (lem:delete-next-char)))

(define-key lem-paredit-mode:*paredit-mode-keymap*  "M-\"" 'paredit-quote-wrap)


;;; Basic Mappings

;; Working on C-W for delete word
;; (defvar testing nil)
;; (setq lem::*set-location-hook* '())
;; (lem:add-hook lem::*set-location-hook*
;;               (lambda (buffer)
;;                 (declare (ignorable buffer))
;;             (if (lem::buffer-mark-p (lem::current-buffer))
;;                     (setq testing t)
;;                     (setq testing t))))

(define-key lem:*global-keymap* "C-x C-@" 'lem.go-back:go-back)
(define-key lem:*global-keymap* "C-h B" 'lem:describe-bindings)
(define-key lem:*global-keymap* "C-h k" 'lem:describe-key)
(define-key lem:*global-keymap* "C-h a" 'lem-lisp-mode:lisp-apropos)
(define-key lem:*global-keymap* "C-h p" 'lem-lisp-mode:lisp-apropos-package)
(define-key lem:*global-keymap* "C-h f" 'lem-lisp-mode:lisp-describe-symbol)

(define-key *global-keymap* "Return" 'lem.language-mode:newline-and-indent)
(setf *scroll-recenter-p* nil)

(define-command add-dir-to-asdf () ()
  (add-dir-to-asdf))

(defun add-dir-to-asdf (&optional directory)
  (let ((dir (or directory (uiop:getcwd))))
    (if (find dir asdf:*central-registry*)
        (error (format nil "The directory ~a is already in ~a"
                       dir asdf:*central-registry*))
        (push (uiop:getcwd)
              asdf:*central-registry*))))

;;; Better Whitespace
(load-library "trailing-spaces")
(lem:add-hook lem:*find-file-hook*
              (lambda (buffer)
                (change-buffer-mode
                 buffer 'lem-trailing-spaces::trailing-spaces t)))

(lem:set-attribute 'lem-ncurses::popup-border-color
                   :foreground "#333333"
                   :background nil
                   :reverse-p t)

;;; Async shell
(defun my-run-command (command &optional buffer-name)
  (lem-shell-mode::create-shell-buffer
   (lem-process:run-process command
                            :name (or buffer-name command)
                            :output-callback 'lem-shell-mode::output-callback
                            :output-callback-type :process-input)))

(define-command async-command (command) ("sAsync shell command: ")
    (setf (current-window)
          (display-buffer (my-run-command
                           (split-sequence #\space command)))))

(define-key lem:*global-keymap* "M-&" 'async-command)

;;; Directory
(define-key lem.directory-mode::*directory-mode-keymap* "-"
  'lem.directory-mode::directory-mode-up-directory)

;;; Override site-init-path
;; (defun xdg-config-path ()
;;   (uiop:file-exists-p
;;    (concatenate 'string (uiop:getenv
;;                          "XDG_CONFIG_HOME")
;;                 (format nil "/lem/~A.asd" lem::*site-init-name*))))

;; (defun lem::site-init-path ()
;;   (let ((path
;;           (or  (xdg-config-path)
;;                (merge-pathnames (format nil ".lem/~A.asd"
;;                                         lem::*site-init-name*)
;;                                 (lem::user-homedir-pathname)))))
;;     (with-open-file (out (ensure-directories-exist path)
;;                          :direction :output
;;                          :if-exists nil)
;;       (format out "~A~%~(~S~)~%"
;;               lem::*site-init-comment
;;               `(asdf:defsystem ,lem::*site-init-name*)))
;;     path))

;;; Golang
(defun go-run (&optional file)
  (let* ((file (or file
                   (lem:buffer-filename (lem:current-buffer))))
         (command (list "go" "run"  file))
         (buf-name (list "go" "run"
                         (subseq file (1+ (position #\/ file :from-end t))))))
    (setf (current-window)
          (display-buffer (my-run-command command buf-name)))))

;; (lem-lsp-mode/lsp-mode::define-language-spec (c-spec lem-c-mode:c-mode)
;;   :language-id "c"
;;   :root-uri-patterns '("makefile" "Makefile")
;;   :command '("clangd" "-background-index")
;;   :mode :stdio)

;; (define-language-spec (rust-spec lem-rust-mode:rust-mode)
;;   :language-id "rust"
;;   :root-uri-patterns '("Cargo.toml")
;;   :command '("rls")
;;   :mode :stdio)