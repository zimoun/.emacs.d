;; -*- lexical-binding: t -*-


;; numbering lines (and add column in mode-line)
(use-package linum
  :defer t
  :init
  (global-linum-mode 0)
  (setq linum-format "%d ")
  ;; to display the number of the column
  (column-number-mode t)
  (setq column-number-indicator-zero-based nil)

  ;; because linum-mode is replaced by `display-line-numbers-mode'
  ;;;; see my-pkg.el package linum
  (defalias 'mode-linum-old '(lambda (&optional args)
                           (interactive)
                           (progn
                             (message "Deprecated. Instead: M-x display-line-numbers-mode. Turn off: M-x linum-mode.")
                             (linum-mode args))))

  (defalias 'mode-linum 'display-line-numbers-mode)

  :config
  (defcustom linum-disabled-modes-list '(
                                         compilation-mode
                                         dired-mode
                                         doc-view-mode
                                         tex-shell-mode
                                         )
    "* List of modes disabled when global linum mode is on"
    :type '(repeat (sexp :tag "Major mode"))
    :tag " Major modes where linum is disabled: "
    :group 'linum
    )
)

;; highlight parens
(use-package paren
  :config
  (show-paren-mode 1)
  ;; not sure it is the right place here
  (electric-pair-mode 1)
  ;; not sure what it does
  (electric-indent-mode 1)
)

;; easy Lisp manipulation with paredit
(use-package paredit
  :ensure t
  :defer t
  ;; :diminish paredit-mode
  :init
  (add-hook 'emacs-lisp-mode-hook 'paredit-mode)
  (add-hook 'scheme-mode-hook 'paredit-mode)
  ;; (add-hook 'emacs-lisp-mode
  ;;           (lambda ()
  ;;             (define-key emacs-lisp-mode-map
  ;;               (kdb "C-k") 'my/paredit-kill)
  ;;             ))
  :bind
  (("C-k" . my/paredit-kill)
   ("RET" . my/ilectrify-return-if-match))

  :config
  (diminish 'paredit-mode "ParEd")
  )


;; save history
(use-package savehist
  :config
  (savehist-mode 1)
)


;; the nice buffer management
(use-package ibuffer
  :defer t
  :init
  ;; C-x C-b ibuffer as default
  (defalias 'list-buffers 'ibuffer)
  (setq ibuffer-saved-filter-groups
        (quote (("default"
                 ("C/C++" (or
                           (mode . c-mode)
                           (mode . c++-mode)
                           ;; (name . "\\.c$")
                           ))
                 ("H/Hpp" (or
                           (mode . c-mode)
                           (mode . c++-mode)
                           ))
                 ("Haskell" (mode . haskell-mode))
                 ("caML" (mode . tuareg-mode))
                 ("ELisp" (mode . emacs-lisp-mode))
                 ("Scheme" (mode . scheme-mode))
                 ("Lisp" (mode . lisp-mode))
                 ("(La)TeX(info)" (or
                             (mode . tex-mode)
                             (mode . latex-mode)
                             (mode . texinfo-mode)
                             (name . "^\\*tex-shell\\*$")
                             ))
                 ("Py" (or
                        (mode . python-mode)
                        (name . "^\\*Python.*\*$")
                        ))
                 ("ESS[R/jl]" (or
                            (mode . ess-mode)
                            (mode . ess-r-mode)
                            (mode . ess-julia-mode)
                            (name . "^\*R.*\*$")
                            ))
                 ("Org" (mode . org-mode))
                 ("PDF" (name . "^[a-zA-Z0-9]*\.pdf$"))

                 ;; ("magit" (name . "^\\*magit.[-_:a-zA-Z0-9 ]+$"))
                 ("Magit" (or
                           (name . "\*magit")
                           (name . "^magit")))
                 ("Dired" (mode . dired-mode))
                 ("Run" (or
                         ;; (name . "^\*eshell\*$")
                         (name . "^\*eshell.*\*$")
                         (mode . shell-mode)
                         (name . "^\\*compilation\\*$")
                         (name . "^\*Inferior Octave\*$")
                         ))
                 ;; ("emacs" (or
                 ;;           (name . "^\\*scratch\\*$")
                 ;;           ;; (name . "^\\*Messages\\*$")
                 ;;           ;; (name . "^\\*Help\\*$")
                 ;;           ;; (name . "^\\*Completions\\*$")
                 ;;           ;; (name . "^\\*Calculator\\*$")
                 ;;           ;; (name . "^\\*Calendar\\*$")
                 ;;           ;; (name . "^\\*Calc Trail\\*$")
                 ;;           ;; (name . "^\\*Compile-Log\\*$")
                 ;;           (name . "^\\*tramp.*\\*$")
                 ;;           ))
                 ("Info" (or
                          (mode . Info-mode)
                          (mode . help-mode)
                          ))
                 ("emacs" (or
                           (name . "^\\*[a-zA-Z+:#0-9 -]*\\*$")
                           (mode . debbugs-gnu-mode)
                           (mode . erc-mode)
                           )
                  )

                 ;; Match any string not containing any uppercase letter
                 ;; ("lower" (name . "\\`[^[:upper:]]*\\'"))
                 ;; Not sure what is doing
                 ;; ("Upper" (name . "[[:upper:]]"))
  ))))
  (add-hook 'ibuffer-mode-hook
            (lambda ()
              (setq-local case-fold-search nil)
              (ibuffer-switch-to-saved-filter-groups "default")))
  (setq ibuffer-show-empty-filter-groups nil)

  ;; sort by alphabetic order instead of (default) recency
  (setq ibuffer-default-sorting-mode 'alphabetic)

  ;; M-o is currently binded
  ;; by default in IBuffer `ibuffer-visit-buffer-1-window'
  ;; and these rebind does not work.
  (local-unset-key (kbd "M-o"))
  (local-set-key (kbd "M-o") 'other-window)
  (global-set-key (kbd "M-o") 'other-window)
  )

;; files manager
(use-package dired
  :defer t
  :init (defalias 'list-directory 'dired)
  ;; ;; Global bind and not only for Dired mode
  ;;:bind ("\C-ce" . dired-toggle-read-only)
  :config
  (setq dired-listing-switches "-alh")
  (define-key dired-mode-map (kbd "r") 'my/dired-sort)
  (define-key dired-mode-map (kbd "=") 'my/dired-ediff-or-diff)
  (define-key dired-mode-map (kbd "E") 'dired-toggle-read-only)

  ;; change confirmation style
  ;;; because the confirmation style is hard coded
  (defalias 'dired--yes-no-all-quit-help 'y-or-n-p)

)

;; Emacs shell
(use-package eshell
  :defer t
  :after em-alias			; load eshell-aliases-file
  :bind
  (("C-d" . eshell/close-or-delete-char)
   ("C-k" . kill-line))
  :init
  (add-hook 'eshell-first-time-mode-hook
            (lambda ()
              (add-to-list 'eshell-visual-commands "htop")
              (add-to-list 'eshell-visual-commands "ssh")
              (add-to-list 'eshell-visual-commands "tail")
              (add-to-list 'eshell-visual-commands "tree")))

  (setq
   eshell-history-size 5000
   eshell-save-history-on-exit t
   eshell-where-to-jump 'begin
   eshell-review-quick-commands nil
   ;; howardism :-)
   eshell-scroll-to-bottom-on-input 'all
   eshell-error-if-no-glob t
   eshell-hist-ignoredups t
   eshell-prefer-lisp-functions nil
   eshell-destroy-buffer-when-process-dies t
   )

  ;;; trick used by Guix
  ;; because EShell does not support some special characters
  ;; for example ]8;;
  ;(setenv "INSIDE_EMACS" "1")

  :config
  (setq eshell-prompt-function
        (lambda nil
          (concat
           "\n"
           (replace-regexp-in-string
            (getenv "HOME") "~" (eshell/pwd))
           "\n $ "
           )
          ;;"\n"(user-login-name) "@" (system-name) " $ ")
          )
        )


  (defvar my/aliases-define-file
    "~/.emacs.d/el/my-aliases.el"
    "File where the list of aliases is defined.")


  ;; add ivy support to completion (TAB activates ivy)
  (add-hook 'eshell-mode-hook
          (lambda ()
            (eshell-cmpl-initialize)
            (define-key eshell-mode-map [remap eshell-pcomplete] 'completion-at-point)
            (define-key eshell-mode-map (kbd "C-r") 'counsel-esh-history)
            (define-key eshell-mode-map (kbd "C-c r") 'isearch-backward)
            ))


  (defun my/eshell-alias (aliases)
    "Write the list ALIASES of cons cells to `eshell-aliases-file'.

Check if `my/aliases-define-file' is newer than `eshell-aliases-file' to stay up-to-date."
    (when (or
           (file-newer-than-file-p my/aliases-define-file eshell-aliases-file)
           (not (file-exists-p eshell-aliases-file)))
      (progn
        (delete-file eshell-aliases-file)
        (with-temp-file eshell-aliases-file
          (mapcar #'(lambda (arg)
                      (let ((name (car arg))
                            (command (cdr arg)))
                        (insert (format "alias %s %s\n" name command))))
                  aliases)))))


  (defun eshell/git-status (&rest args)
    "Alias as function to `magit-status'.

If ARGS is nil, then open `magit-status' in `default-directory'.
Else open it in first ARGS.

If other ARGS is non-nil, then offer to initialize it
as a new repository."
    (let ((a-dir (if args
                     (pop  args)
                   default-directory))
          (create (if args
                      (pop args)
                    nil)))
      (if (file-directory-p a-dir)
          (if (file-directory-p (concat a-dir "/.git"))
              (magit-status a-dir nil)
            (if create
                (magit-status a-dir nil)
              (eshell/echo (format "Try: git-status %s init" a-dir))))
        (message "Error: %s is not a directory." a-dir))))


  (defun eshell/clear ()
    "Clear the eshell buffer."
    (let ((inhibit-read-only t))
      (erase-buffer)
      (eshell-send-input)))

  (defun eshell/close ()
    (progn
      (eshell-life-is-too-much)
      (ignore-errors (delete-frame))))

  (defun eshell/close-or-delete-char (arg)
    "Kill the current buffer (eshell one expected) and close the frame."
    (interactive "p")
    (if (and (eolp) (looking-back eshell-prompt-regexp))
        (progn
          (eshell-life-is-too-much)      ; Why not? (eshell/exit)
          (ignore-errors
            (delete-frame)))
      (delete-forward-char arg)))

  (defun eshell/find-grep (&rest args)
    "Wrapper of `find-grep' to ease with Info node `(eshell)'.

Two use cases:
 1. find-grep <REGEXP>
 2. find-grep <PATH> <REGEXP>
where <REGEXP> is a pattern.

If <PATH> is omitted, `default-directory' is used (current one). See `my/find-grep'."
    (let (regexp
          (dir nil))
      (if (= (length args) 1)
          (setq regexp (pop args))
        (progn
          (setq dir (pop args))
          (setq regexp (pop args))))
      (my/find-grep regexp dir)))


  (defun eshell/pdfcat (&rest args)
    "Wrapper of Ghostscript (GS) to concatenate PDF files.

Use: pdfcat outfile infile1 infile2 foo*.pdf infile3 ..."
    (cond
     ((= (length args) 0)
      (error "pdfcat outfile infile1 infile2 foo*.pdf infile3 ..."))
     ((= (length args) 1)
      (error "pdfcat needs more than only one files."))
     ((= (length args) 2)
      (let* ((outfile (pop args))
             (infile (pop args)))
        (copy-file infile outfile)))
     (t
      (let* ((todo (make-progress-reporter "eshell/pdfcat..."))
             (outfile (pop args))
             (infiles (mapconcat 'identity args " "))
             (cmd "gs -q -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -sOutputFile=")
             (s (concat cmd outfile " " infiles)))
        (message (format "in : %s\nout: %s\n%s" infiles outfile s))
        (shell-command-to-string s)
        (progress-reporter-done todo)))))

  (defun eshell/pdfextract (&rest args)
    "Wrapper of Ghostscript (GS) to extract pages in PDF file.

Use: pdfextract myfile #first #last"
    (let (first
          last
          (rev-args (reverse args)))
      (cond
       ((< (length args) 2)
        (error "pdfextract myfile #first #last"))
       ((= (length args) 2)
        (progn
          (setq first (pop rev-args))
          (setq last first)))
       ((= (length args) 3)
        (progn
          (setq last (pop rev-args))
          (setq first (pop rev-args))))
       (t
        (error "Error: wrong number of arguments.")))

      (setq first (number-to-string first))
      (setq last (number-to-string last))

      (let* ((todo (make-progress-reporter "eshell/pdfextract..."))
             (name (pop rev-args))
             (sans (file-name-sans-extension name))
             (out (concat sans "_p" first "-p" last ".pdf"))
             (cmd "gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dSAFER")
             (s (format "%s -dFirstPage=%s -dLastPage=%s -sOutputFile=%s %s"
                         cmd first last out name)))
        (shell-command-to-string s)
        (progress-reporter-done todo))))

  (defun eshell/pdfview (&rest args)
    "Wrapper of 'find [path|.] -type f -name \"*myfile*.pdf\" -print -exec mupdf {} \;'

Note: the alias of mupdf is unknown.    ;; FIXME

Use: pdfview pattern [path]"
    ;; TODO: allow regexp as pattern
    (let (pattern
          (dir default-directory))
      (cond
       ((= (length args) 0)
        (error "pdfview pattern [path]"))
       ((= (length args) 1)
        (setq pattern (pop args)))
       ((= (length args) 2)
        (progn
          (setq pattern (pop args))     ;FIXME: expand as regexp
          (setq dir (pop args))))
       (t
        (error "Error: wrong number of arguments.")))
      (let ((f (file-name-sans-extension pattern))
            ;;(mupdf "~/.guix-profile/bin/mupdf-x11")
            (mupdf "mupdf-x11")
            )
        (shell-command-to-string (format "find %s -type f -name '*%s*.pdf' -print -exec %s {} \\;"
                                         dir f mupdf)))))

  (use-package esh-toggle
    :defer t
    :bind ("C-x C-z" . eshell-toggle)
    )
)

(use-package shell
  :defer t
  :config
  (add-hook 'shell-mode-hook
          (lambda ()
            (define-key shell-mode-map (kbd "C-d")
              'my/comint-delchar-or-maybe-eof)
            (define-key shell-mode-map (kbd "C-r") 'counsel-shell-history)
            ))

  ;; Redefine M-p/M-n because old habits
  (define-key shell-mode-map (kbd "<up>") 'comint-previous-input)
  (define-key shell-mode-map (kbd "<down>") 'comint-next-input)

  (defun my/comint-delchar-or-maybe-eof (arg)
  "See `comint-delchar-or-maybe-eof' with `kill-current-buffer'."
  (interactive "p")
  (let ((proc (get-buffer-process (current-buffer))))
    (if (and (eobp) proc (= (point) (marker-position (process-mark proc))))
        (progn
          (comint-send-eof)
          (kill-current-buffer)
          )
      (delete-char arg))))

  )

;; Bookmark facilities
(use-package bookmark
  :defer t
  ;; :init
  ;; (bookmark-bmenu-list)
  ;; (switch-to-buffer "*Bookmark List*")
  :config
  (setq bookmark-save-flag t)
  (setq bookmark-version-control t)
  )

(use-package diminish
  :ensure t
  :defer t
  )

;; show function signature in Mini-Buffer
(use-package eldoc
  :defer t
  :diminish t
  :config
  (diminish 'eldoc-mode)
  )

;; ;;
;; ;; Hum? not sure it works as I want.
;; ;; And it adds possibly long stuff in the (short) mode line.
;; ;;
;; ;; display the current function in mode line
;; (use-package which-func
;;   ;; which-func-mode is deprecated
;;   ;; but which-function-mode is defined in which-func.el
;;   :init
;;   (which-function-mode t)
;;   (setq which-func-unknown ".")
;;   (setq which-func-modes
;;         '(python-mode
;;           lisp-mode
;;           julia-mode
;;           ess-mode
;;           cc-mode
;;           ))
;; )

;; ELisp
(use-package lisp-mode
  :defer t
  :init
  ;; because it seems more matural to me
  (defalias 'run-elisp 'ielm)
  :config
  (add-hook 'emacs-lisp-mode-hook 'eldoc-mode)
  (add-hook 'emacs-lisp-mode-hook 'my/save-file-and-remove-filec)
)

;; remote editing
(use-package tramp
  :defer t
  :config
  (setq tramp-default-method "ssh")
  ;; (setq tramp-auto-save-directory
  ;;       (concat user-emacs-directory "tramp-auto-save"))
)

;; ;; catch all the keys
;; (use-package keyfreq
;;   :ensure t
;;   :config
;;   (keyfreq-mode 1)
;;   (keyfreq-autosave-mode 1)
;;   (setq keyfreq-file "~/.emacs.d/emacs-keyfreq")
;;   (setq keyfreq-autosave-timeout 1)
;; )

;; C/C++ stuffs
(use-package cc-mode
  :defer t
  :config
  (setq c++-default-style "linux")
  (setq c++-basic-offset 4)
  ;; c++/c should be merged ? (with mode-common?)
  (setq c-default-style "linux")
  (setq c-basic-offset 4)

  ;; ;; Or conserve TAB style
  ;; (setq-default c-basic-offset 8
  ;;                 tab-width 8
  ;;                 indent-tabs-mode t)

  (add-hook 'c-mode-common-hook 'hs-minor-mode)
  (add-hook 'c-mode-common-hook 'my/return-newline-with-indent)

  ;; add better completion
  ;(add-hook 'c-mode-common-hook 'semantic-mode)
  ;(add-hook 'c-mode-common-hook 'semantic-idle-completions-mode)
  ;(add-hook 'c-mode-common-hook 'semantic-highlight-func-mode)
  ;;(add-hook 'c-mode-common-hook 'semantic-stickyfunc-mode)

  (add-hook 'c-mode-common-hook 'eldoc-mode)
)

;; python (which mode ?)
(use-package python
  :ensure t
  :defer t
  :mode ("\\.pyx$" . python)
  ;; hum? not sure to understand init/config mechanism
  ;; if I understand well,
  ;; the first hook is applied at startup time
  ;; the second hook is applied when python is required.
  :init
  (add-hook 'python-mode-hook 'eldoc-mode)
  (setq python-shell-interpreter "ipython"
        python-shell-interpreter-args "-i --simple-prompt")
  :config
  (define-key inferior-python-mode-map (kbd "<up>") 'comint-previous-input)
  (define-key inferior-python-mode-map (kbd "<down>") 'comint-next-input)
  (add-hook 'python-mode-hook 'my/return-newline-with-indent)
  ;; Need to define function something in this flavor
  ;; in order to create the TAGS file
  ;; Should run etags even in the imported lib
  ;; workon foo
  ;; find ${$(which python)/\/bin\/python/} -type f -name '*.py' | xargs etags
)


;; LaTeX
(use-package tex-mode
  :defer t
  :config
  (add-hook 'latex-mode-hook 'my/return-newline-with-indent)
  (setq revert-without-query '(".+pdf$"))
  ;; Latex hook
  ;; be careful, not latex-mode-hook but tex-mode-hook !!
  (add-hook 'tex-mode-hook
          (lambda ()
            (define-key tex-mode-map (kbd "C-c C-r") 'my/compile-or-recompile)
            (define-key tex-mode-map (kbd "C-c C-S-R") 'tex-region)
            )
          )
  ;; Automatically bound paragraph length
  (add-hook 'latex-mode-hook 'turn-on-auto-fill)
  ;; the so nice RefTeX package...
  (add-hook 'latex-mode-hook 'turn-on-reftex)
  (setq reftex-ref-macro-prompt nil)

  ;; add the underlining of mistakes
  (add-hook 'tex-mode-hook 'flyspell-mode)

  ;; replace internal DocView-mode by external MuPDF
  ;; (see package openwith somewhere there)
  (openwith-mode t)
)

;; I do not used it but required by cdlatex
;;; because of texmathp
(use-package auctex
  :ensure t
  :defer t)

;; mispell corrector using dictionary
(use-package ispell
  :defer t
  :init
  (global-set-key [?\C-$] 'ispell-region)
  ;;;;;;;; C-$ does not work in terminal
  (global-set-key [f1] 'ispell-buffer)
  (global-set-key [f11] 'flyspell-buffer)
  (global-set-key [f12] 'flyspell-mode)
  :config
  (setq-default ispell-program-name "aspell")
)

(use-package flycheck
  :ensure t
  :defer t
  :init
  (global-flycheck-mode)
  (setq flycheck-disabled-checkers '(emacs-lisp-checkdoc))
  )

;; OCalm improved mode
(use-package utop
  :ensure t
  :defer t)
(use-package tuareg
  :ensure t
  :defer t
  :mode ("\\.ml[ily]?$" . tuareg-mode)
  :bind (:map tuareg-mode-map
         ("C-c C-e" . utop-eval-phrase))
  :init
  (defalias 'run-ocaml 'utop)
  :config
  (autoload 'utop "utop" "Toplevel for Ocaml" t)
  (autoload 'utop-minor-mode "utop" "Minor mode for utop/ocaml" t)
  ;; (autoload 'utop-setup-ocaml-buffer "utop" "Toplevel for Ocaml" t)
  (add-hook 'tuareg-mode-hook 'utop-minor-mode)
)

;; Lua used by Awesome
(use-package lua-mode
  :ensure t
  :defer t
  :mode ("\\.lua$" . lua-mode)
)

;; octave and so on
(use-package octave
  :ensure t
  :defer t
  :mode ("\\.m\\'" . octave-mode)
  :config
  (setq octave-mode-hook
      (lambda () (progn (setq octave-comment-char ?%)
                        (setq comment-start "% ")
                        (setq comment-add 0))))
)
;; Editing blog
(use-package markdown-mode
  :ensure t
  :defer t
  :mode ("\\.md\\'" "\\.mkd\\'" "\\.markdown\\'")
  :config
  (progn
    (add-hook 'markdown-mode-hook 'auto-fill-mode)
    (setq markdown-open-command "marked")
  )
)


;; see if useful ?
(use-package pandoc-mode
  :ensure t
  :defer t
  :config
  (add-hook 'markdown-mode-hook 'pandoc-mode)
  ;; (add-hook 'org-mode-hook 'pandoc-mode)
  (add-hook 'pandoc-mode-hook 'pandoc-load-default-settings)
)


;; Org-anize my life
(use-package org
  :ensure org-plus-contrib		; ensure the last version of Org
  :defer t

  :bind (("\C-ca"  . my/org-agenda)
	 ("\C-cl"  . org-store-link))

  :init
  ;; Need to be initialized before Org is loaded
  (setq org-enforce-todo-dependencies t)

  :config
  ;; More "intuitive" beginning of line
  (setq org-special-ctrl-a/e t)

  ;; hook to limit the number of characters per line
  ;; this number is controled by the variable fill-column
  (add-hook 'org-mode-hook 'turn-on-auto-fill)

  ;; add the underlining of mistakes
  (add-hook 'org-mode-hook 'flyspell-mode)

  ;; add cdlatex to ease typing math
  ;;;; dependency to auctex because of texmathp
  (add-hook 'org-mode-hook 'turn-on-org-cdlatex)

  ;; My prefered and used backends
  ;;;; need to be set up before loading org.el
  ;; (or not, depending on Emacs's version ?)
  (setq org-export-backends '(ascii html latex texinfo))

  (setq org-agenda-files (list
                          "~/org/"
                          ))
  (setq org-agenda-include-diary nil)

  ;; ;; take advantage of the screen width
  ;;(setq org-agenda-tags-column -100)

  (setq org-tag-faces
        '(
          ;;("@meet" . (:foreground "Chartreuse4" :weight bold :underline t))
          ("@meet" . (:foreground "mediumseagreen" :weight bold :underline t))
          ("URGENT" . (:foreground "Red" :underline t))
          ))


  (put 'narrow-to-region 'disabled nil)
  (org-babel-do-load-languages
   'org-babel-load-languages '((python . t)
                               (R . t)
                               (C . t)
                               (shell . t)
                               (org . t)
                               (makefile . t)
                               (scheme . t)
                               ))
                               ;(bash . t)))
  ;; do not ask before eval code blocks
  (setq org-confirm-babel-evaluate nil)
  ;; In org-mode 9 you need to have #+PROPERTY: header-args :eval never-export
  ;; in the beginning or your document to tell org-mode not to evaluate every
  ;; code block every time you export.

  ;; C-c ' do not indent when leaves
  (setq org-edit-src-content-indentation 0)

  ;; insert image
  ;; just after a block is executed
  (add-hook 'org-babel-after-execute-hook 'org-display-inline-images)
  ;; when org file is opened
  (add-hook 'org-mode-hook 'org-display-inline-images)
  (add-hook 'org-mode-hook 'org-babel-result-hide-all)

  ;; store time when TODO is DONE
  (setq org-log-done (quote time))

  (setq org-src-fontify-natively t)     ; coloring   inside blocks
  (setq org-src-tab-acts-natively t)	; completion inside blocks)
  (setq org-src-window-setup 'current-window)
  ;; (setq org-hide-emphasis-markers t)    ; hide the *,=, or / markers
  (setq org-cycle-separator-lines 1)    ; number of empty lines
                                        ; needed to keep empty
                                        ; between collapsed trees




  ;; Follow internal link C-c C-l
  ;;;; file:stuff.org::Key1 key2
  ;;;; then C-c C-o open the link searching with the keywords Key1 key2
  ;;;; The search is fuzzy. Otherwise, by default 'query-replace-to it is strict.
  (setq org-link-search-must-match-exact-headline nil)


  ;; Add notes (C-c C-z) in LOGBOOK
  (setq org-log-into-drawer t)

  ;; Set quick capture
  (defalias 'orgadd 'org-capture)
  (setq org-capture-templates
        (quote
         (("t" "Todo")
          ("tt" "TODO entry" entry
           (file+headline "~/org/todo.org" "Capture")
           (file "~/.emacs.d/org-templates/todo.org"))
          ("tm" "Misc and URGENT" entry
           (file+headline "~/org/todo.org" "Misc")
           (file "~/.emacs.d/org-templates/urgent.org"))
          ("d" "Diary" entry
           (file+headline "~/org/diary.org" "Capture")
           (file "~/.emacs.d/org-templates/done.org"))
          ("b" "Bookmark" entry
           (file+headline "~/org/bookmarks.org" "Bookmarks")
           "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n\n" :empty-lines 1))
     ))

  (if (not (version-list-< '(9 2) (version-to-list org-version)))
      (progn
        (warn "Please update Org-mode.\ne.g., by installing `org-plus-contrib'.\nKeybindings <s need `(require 'org-tempo)' to work again.")
        ;; Try <el TAB
        (add-to-list 'org-structure-template-alist
                     '("el" "#+BEGIN_SRC emacs-lisp\n?\n#+END_SRC")))
    (progn
      ;; With 9.2 the keybindings <s does not work anymore
      ;; The Org Tempo allow the previous mechanism
      ;; https://orgmode.org/Changes.html#org1b5e967
      (require 'org-tempo)
      ;; see org-structure-template-alist
      (add-to-list 'org-structure-template-alist
		           '("sel" . "src emacs-lisp")))
    )

  ;; Add the support of LaTeX macro when exporting (pdf or html)
  ;;;; Write your LaTeX macros in source block latex-macro1
  (add-to-list 'org-src-lang-modes '("latex-macro" . latex))

  (defvar org-babel-default-header-args:latex-macro
    '((:results . "raw drawer")
      (:exports . "results")))

  (defun org-babel-execute:latex-macro (body _params)
    (defun prefix-all-lines (pre body)
      (with-temp-buffer
        (insert body)
        (string-insert-rectangle (point-min) (point-max) pre)
        (buffer-string)))
    (concat
     (prefix-all-lines "#+LATEX_HEADER: " body)
     "\n#+HTML_HEAD_EXTRA: <div style=\"display: none\"> \\(\n"
     (prefix-all-lines "#+HTML_HEAD_EXTRA: " body)
     "\n#+HTML_HEAD_EXTRA: \\)</div>\n"))


  (defun org-latex-export-as-latex-only ()
    "How to customize `org-export-dispatch'?"
    (interactive)
    (org-latex-export-as-latex nil nil nil t nil))

  (defun org-latex-export-to-latex-only ()
    "How to customize `org-export-dispatch'?"
    (interactive)
    (org-latex-export-to-latex nil nil nil t nil))
)

;; graphviz support
(use-package graphviz-dot-mode
  :ensure t
  :defer t
)

;; (use-package julia-mode
;;   :ensure t
;;   :defer t
;;   :mode ("\\.jl$" . julia-mode)
;;   ;; :config
;;   ;; ;(require 'ess-site)
;;   ;; (setq inferior-ess-julia-program-name "julia")
;; )

(use-package magit
  :ensure t
  :defer t
  :bind (("C-x g" . magit-status)
         ("C-x C-g b" . magit-blame)
         ("C-x C-g l" . magit-log-buffer-file)
         ("C-x C-g C-l" . magit-show-commit)
         ("C-x C-g C-t" . magit-toggle-buffer-lock)
         ("C-x C-g C-f" . magit-find-file))
  :config
  ;;   (add-hook 'magit-section-set-visibility-hook
  ;;             'my/magit-initially-hide-untracked)
  (setq magit-view-git-manual-method 'woman)
  (add-hook 'magit-status-sections-hook 'magit-insert-recent-commits)
)


(use-package yasnippet
  :ensure t
  :defer t
  :diminish t
  :init
  (yas-global-mode 1)
  :config
  (yas-global-mode 1)
  (diminish 'yas-minor-mode)
  )

;; (use-package elpy
;;   :ensure t
;;   :config
;;   (elpy-enable))

(use-package pyvenv
  :ensure t
  :defer t
  :init
  ;; hum? is it possible to have alias per mode
  ;; i.e., here only with Python
  (defalias 'workon 'pyvenv-workon)
  :config
  (setq python-shell-interpreter "ipython"
        python-shell-interpreter-args "-i --profile=ipy --simple-prompt")
  ;; Python and conda env
  (setenv "WORKON_HOME" "~/miniconda2/envs")
  (pyvenv-mode 1)
)

(use-package ess
  :defer t
  :ensure t
  :init
  :defines ess-indent-offset
  :mode (
         ("\\.[r|R]\\'" . R-mode)
         ("\\.jl\\'" . ess-julia-mode)
        )
  :config
  (require 'ess-julia)
  (require 'ess-utils)
  ;(require 'ess-rutils)
  (add-hook 'R-mode-hook
            (lambda ()
              (progn
                (ess-set-style 'RStudio)
                (setq ess-indent-offset tab-width)

                ;; Not sure this is still useful
                ;; remap (default) "_" to "<-" by "=" to "<-"
                (setq ess-smart-S-assign-key "=")
                ;; needs to double `(ess-toggle-S-assign nil)'
                (ess-toggle-S-assign nil)
                (ess-toggle-S-assign nil)

                ;; Fix the assign
                (local-set-key (kbd "=") 'ess-cycle-assign)
                )))
  (setq ess-assign-list '(" <- " " = " " <<- " " -> " " ->> "))
  (setq ess-eval-visibly-p nil)
  (setq ess-use-eldoc'script-only)
  ;; (add-hook 'R-mode-hook
  ;;           (lambda ()
  ;;             (local-set-key (kbdb "=" 'ess-cycle-assign))
  ;;             ))
  (setq inferior-julia-program-name "/home/simon/local/julia-1.0.3/bin/julia")
)


(use-package poly-markdown
  :defer t
  :ensure t
  :mode (("\\.md" . poly-markdown-mode)
	 ("\\.Rmd" . poly-markdown-mode)
	))

;; (use-package ess-site
;;   :ensure ess
;;   :mode (
;;          ("\\.R\\'" . R-mode)
;;          ;("\\.jl\\'" . julia-mode)
;;          )
;;   :defines ess-indent-offset
;;   :config
;;   (add-hook 'R-mode-hook
;;             (lambda ()
;;               (setq ess-indent-offset tab-width)))
;;   (require 'ess-rutils)
;;   (setq ess-eval-visibly-p nil)
;;   ;; change "_" to "<-" by "=" to "<-"
;;   ;; the double `(ess-toggle-S-assign nil)'
;;   (setq ess-smart-S-assign-key "=")
;;   (ess-toggle-S-assign nil)
;;   (ess-toggle-S-assign nil)
;;   ;;(setq ess-indent-level 2)
;;   (ess-set-style 'RStudio)
;;   ;;(setq ess-use-eldoc t)
;;   (setq ess-use-eldoc'script-only)
;; )


(use-package geiser
  :ensure t
  :defer t
  :init
  ;; scheme
  (setq scheme-program-name "guile")
  ;;(setq geiser-default-implementation 'guile)
  ;;(setq geiser-default-implementation '(guile))
  :config
  (add-hook 'scheme-mode-hook 'geiser-mode)
  ;; (setq geiser-default-implementation '(guile))
  ;; (setq geiser-implementation-alist '(((regexp "\\.scm$") guile)))
  (setq geiser-active-implementations '(guile))
  ;;(setq geiser-guile-binary "/home/simon/.guix-profile/bin/guile")
  )

(use-package openwith
  :ensure t
  :defer t
  :config
  ;; because Doc-View mode is not efficient enough for large PDF documents
  (setq openwith-associations '(("\\.pdf\\'" "mupdf" (file))))
)

(use-package pdf-tools
  :ensure t
  :defer t
  :config
  ;; guix environment emacs-pdf-tools
  ;; ~/.emacs.d/elpa/pdf-tools-XXXX/build/server/autobuild -i ~/.emacs.d/elpa/pdf-tools-XXXX/
  (message "How to export Annotation to Org/PDF")
  )

;; (use-package bibtex-completion
;;   :ensure t
;;   :defer t
;;   :config
;;   (setq bibtex-completion-bibliography
;;         '("~/tmp/bibjabref.bib"))
;;   )



;; Required by Ivy
;; to propose first the history as candidates when M-x
(use-package smex
  :ensure t
  :defer t
  )

(use-package counsel
  :ensure t
  :defer t
  )

(use-package swiper
  :ensure t
  :defer t
  )


(use-package ivy
  :ensure t
  :defer t
  :bind* (:map ivy-minibuffer-map
               ;; TAB is by default ivy-partial-or-done
               ;; works only with X
               (([tab] . ivy-next-line)))
  :init
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers      t
        ivy-re-builders-alist     '(;(swiper-isearch . ivy--regex-plus)
                                    (t . ivy--regex-ignore-order))
        ivy-virtual-abbreviate   'full  ;switch-buffer with full path in recentf
        enable-recursive-minibuffers t
        ivy-wrap                     t  ; cycle last->first and first->last
        recentf-max-saved-items    nil
        )
  ;(setq ivy-count-format "")
  (global-set-key "\C-s" 'swiper-isearch)
  (global-set-key (kbd "M-x") 'counsel-M-x)
  (global-set-key (kbd "C-x C-f") 'counsel-find-file)
  (global-set-key (kbd "C-x b") 'ivy-switch-buffer)  ;because counsel-switch-buffer unlikely adds preview
  (global-set-key (kbd "M-y") 'counsel-yank-pop)
  (global-set-key (kbd "C-h f") 'counsel-describe-function)
  (global-set-key (kbd "C-h v") 'counsel-describe-variable)
  (global-set-key (kbd "C-c r") 'ivy-resume)
  (global-set-key (kbd "C-c f") 'counsel-git)
  (global-set-key (kbd "C-c g") 'counsel-git-grep)
  (global-set-key (kbd "C-c s") 'counsel-ag)
  (global-set-key (kbd "C-c o") 'counsel-outline)
  (define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history)


  (setq ivy-height 23)

  (diminish 'ivy-mode)

  :config
  ;; Improve the switch (path, mode, etc.)
  (use-package ivy-rich
    :ensure t
    :defer t
    :after counsel
    :init
    ;; see list-faces-display for :face
    (setq ivy-rich-display-transformers-list
          '(ivy-switch-buffer
            (:columns
             ((ivy-rich-candidate (:width 30))
              (ivy-rich-switch-buffer-size (:width 7
                                                   :face dired-ignored
                                                   ))
              ;(ivy-rich-switch-buffer-indicators (:width 4 :face error :align right))
              (ivy-rich-switch-buffer-major-mode (:width 12
                                                         ;:face warning
                                                         ))
              ;(ivy-rich-switch-buffer-project (:width 15 :face success))
              (ivy-rich-switch-buffer-path (:width
                                            (lambda (x) (ivy-rich-switch-buffer-shorten-path x (ivy-rich-minibuffer-width 0.3)))
                                            :face font-lock-doc-face
                                            )))
             :predicate
             (lambda (cand) (get-buffer cand)))

            ;; Unmodified
            counsel-find-file
            (:columns
             ((ivy-read-file-transformer)
              (ivy-rich-counsel-find-file-truename (:face font-lock-doc-face))))
            counsel-M-x
            (:columns
             ((counsel-M-x-transformer (:width 40))
              (ivy-rich-counsel-function-docstring (:face font-lock-doc-face))))
            counsel-describe-function
            (:columns
             ((counsel-describe-function-transformer (:width 40))
              (ivy-rich-counsel-function-docstring (:face font-lock-doc-face))))
            counsel-describe-variable
            (:columns
             ((counsel-describe-variable-transformer (:width 40))
              (ivy-rich-counsel-variable-docstring (:face font-lock-doc-face))))
            counsel-recentf
            (:columns
             ((ivy-rich-candidate (:width 0.8))
              (ivy-rich-file-last-modified-time (:face font-lock-comment-face))))
            package-install
            (:columns
             ((ivy-rich-candidate (:width 30))
              (ivy-rich-package-version (:width 16 :face font-lock-comment-face))
              (ivy-rich-package-archive-summary (:width 7 :face font-lock-builtin-face))
              (ivy-rich-package-install-summary (:face font-lock-doc-face)))))
          )
    (setq ivy-rich-path-style 'abbrev)
    (ivy-rich-mode 1)                   ;turn on the mode after setq ivy-rich-display-transformers-list
    )
  )


;; (use-package ivy-bibtex
;;   :ensure t
;;   :defer t
;;   :config
;;   (setq bibtex-completion-bibliography
;;         '("~/bib/bibjabref.bib"))
;;   (setq bibtex-completion-library-path
;;         (mapcar (lambda (x) (concat "~/bib/pdf/" x))
;;                 '("article/"
;;                 "book/"
;;                 "CO/"
;;                 "conf/"
;;                 "report/"
;;                 "TH/")))
;;   ;; the special JabRef field File is not working
;;   ;; because File stores relative path and ivy-bibtex looks for full path
;;   ;; even if bibtex-completion-library-path is set to "~/bib/pdf/"
;;   ;; (setq bibtex-completion-pdf-field "File")

;;   (setq bibtex-completion-pdf-symbol "#")

;;   ;; replace internal DocView-mode by external MuPDF
;;   ;; (see package openwith somewhere there)
;;   (openwith-mode t)
;; )



(use-package haskell-mode
  :ensure t
  :defer t
  :config
  (require 'haskell-interactive-mode)
  (require 'haskell-process)
  (add-hook 'haskell-mode-hook 'interactive-haskell-mode)

  (add-hook 'haskell-mode-hook 'haskell-doc-mode)

  ;; allow to cycle by TAB
  (add-hook 'haskell-mode-hook 'haskell-indentation-mode)
  ;; not sure if it is useful?
  (setq haskell-indentation-electric-flag t)
  ;; apparently not really maintained.
  ;; however useful haskell-indent-align-guards-and-rhs etc.
  (add-hook 'haskell-mode-hook 'haskell-indent-mode)
  ;; provide e.g., nice beginning-of-defun binded to C-M-a
  (add-hook 'haskell-mode-hook 'haskell-decl-scan-mode)

  (define-key haskell-mode-map (kbd "C-c C-p") 'haskell-interactive-bring)
)

(use-package debbugs
  :ensure t
  :defer t
  :config

  ;; weird because the keymap variable is load at this time
  (with-eval-after-load "debbugs-gnu"
    ;; deactivate Ivy for the function `debbugs-gnu-search'
    ;; Enter attribute indefinitively loops
    ;; because Ivy always suggests a completion
    ;; then it is impossible to enter an empty key
    ;;
    ;; (eval-after-load 'ivy-mode          ; ouch! not work, use hook instead
    ;;   (add-to-list 'ivy-completing-read-handlers-alist '(debbugs-gnu-search)))
    (add-hook 'debbugs-gnu-mode-hook #'(lambda ()
                                        (setq-local completing-read-function
                                                    #'completing-read-default)))

    (setq debbugs-gnu-default-packages '("guix-patches" "guix"))
    (add-to-list 'debbugs-gnu-all-packages "guix-patches")
    (define-key debbugs-gnu-mode-map "N" 'debbugs-gnu-narrow-to-status)
    (define-key debbugs-gnu-mode-map "/" 'debbugs-gnu-search)
    (define-key debbugs-gnu-mode-map "#" 'debbugs-gnu-bugs))

  ;; inspired by Oleg Pykhalov from mailing list
  (defun my/debbugs-query-email (email-address)
    "List all the bug report that EMAIL-ADDRESS has opened."
    (interactive
     (let* ((default "zimon.toutoune@gmail.com")
            (string (read-string (format "Email address (%s): " default))))
       (when (not (equal string ""))
         (setq default string))
       (list default)))
    (let ((debbugs-gnu-current-query `((submitter . ,email-address))))
      (debbugs-gnu nil))
    (message (format "Debbugs current-query: submitter=%s" email-address)))
)

;; Not installed ? How to force install ?
(use-package htmlize
  :ensure t
  :defer t)

(use-package snakemake-mode
  :ensure t
  :defer t
  :mode ("\\.smk$" . snakemake-mode))

(use-package rust-mode
  :ensure t
  :defer t)


(use-package elfeed
  :ensure t
  :defer t
  :bind
  ;; C-c because C-c is one user shortcut (not a mode one)
  ;; and w because we Wowse with the Emacs Web Wowser (eww)
  ;; Return should open the link with the default Browser
  ("\C-cw"  . eww-follow-link)

  :config
  ;; useful to quick read webpages by following links
  (require 'eww)

  ;;change the default location of the Database
  (setq elfeed-db-directory "~/org/.elfeed")

  ;; Mark as read all the feeds older than 1 month
  ;; (there are still readable)
  (add-hook 'elfeed-new-entry-hook
          (elfeed-make-tagger :before "1 month ago"
                              :remove 'unread))
  ;; Default filter: show 1 month new and unread feeds
  (setq-default elfeed-search-filter "@1-month-ago +unread ")
  ;;;; note that the both duration (hook/filter) should be different

  ;; All the feeds that I follow... or not!
  (setq elfeed-feeds
        '(
          ("http://planet.emacsen.org/atom.xml" emacs planet)
          ("http://nullprogram.com/feed/" emacs blog)
          ("https://www.masteringemacs.org/feed" emacs blog)
          ("https://planet.debian.org/atom.xml" debian planet)
          ("https://www.debian.org/News/news" debian)
          ("http://joeyh.name/blog/index.rss" debian blog)
          ("http://www.scheme.dk/planet/atom.xml" lisp scheme planet)
          ("http://planet.lisp.org/rss20.xml" lisp planet)
          ("http://tapoueh.org/index.xml" postgre lisp blog)
          ("https://ocaml.org/feed.xml" ocaml planet)
          ("https://planet.haskell.org/atom.xml" haskell planet)
          ("https://www.gnu.org/software/guix/feeds/blog.atom" guix)
          ("https://guix-hpc.bordeaux.inria.fr/blog/feed.xml" guix)
          ("https://elephly.net/feed.xml" guix)
          ("https://lwn.net/headlines/rss" lwn news)
          ("https://lwn.net/headlines/Features" lwn news)
          ("https://www.fsf.org/static/fsforg/rss/news.xml" fsf news)
          ("https://www.fsf.org/static/fsforg/rss/blogs.xml" fsf blog)
          ("https://www.eff.org/en/rss" eff news)
          ("https://api.quantamagazine.org/feed/" quanta news)
          ("https://phylogenomics.blogspot.com/feeds/posts/default" bioinfo blog)
          ("https://simplystatistics.org/index.xml" bioinfo blog)
          ))
)


;; provide some stats about writings
;;;; writegood-grade-level -> Flesch-Kincaid grade level score
;;;; writegood-reading-ease -> Flesch-Kincaid reading ease score
;;;; https://en.wikipedia.org/wiki/Flesch–Kincaid_readability_tests
(use-package writegood-mode
  :ensure t
  :defer t
  :init (defalias 'mode-writegood 'writegood-mode))


;; useful to demo
(use-package command-log-mode
  :ensure t
  :defer t
  :init
  (defalias 'mode-command-log 'command-log-mode)
  (defalias 'command-log-show '(lambda (&optional arg)
                                 (interactive "P")
                                 (progn
                                   (command-log-mode)
                                   (message "Alias of clm/open-command-log-buffer. See M-x clm/TAB.")
                                   (clm/open-command-log-buffer arg))))
  )


(use-package ox-reveal
  ;; :ensure t
  ;; https://github.com/yjwen/org-reveal/issues/324
  ;; git clone https://github.com/yjwen/org-reveal.git ~/.emacs.d/elpa/org-reveal.git
  ;; WARNING: issue with Org 8.2
  :load-path "~/.emacs.d/elpa/org-reveal.git"
  :defer t
  ;; Do not forget to provide REVEAL_ROOT:
  ;; (setq org-reveal-root "http://cdn.jsdelivr.net/reveal.js/3.0.0")
  ;; or with #+REVEAL_ROOT: http://cdn.jsdelivr.net/reveal.js/3.0.0

  ;; Load it in index.org with: M-: (require 'ox-reveal)
  )

(use-package fill-column-indicator
  :ensure t
  :defer t
  :init
  (defalias 'mode-fci 'fci-mode))


(use-package guix
  :ensure t
  :defer t
  :init
  ;; For specific modes
  (add-hook 'shell-mode-hook 'guix-prettify-mode)
  (add-hook 'eshell-mode-hook 'guix-prettify-mode)
  (add-hook 'dired-mode-hook 'guix-prettify-mode)

  ;; Prettify globally
  ;(add-hook 'after-init-hook 'global-guix-prettify-mode)

  ;; Help for Devel
  (add-hook 'scheme-mode-hook 'guix-devel-mode)
  (add-hook 'shell-mode-hook 'guix-build-log-minor-mode)
  )


;; better than `delete-trailing-whitespace'
;;; (add-hook 'before-save-hook 'delete-trailing-whitespace)
;;; because clean up only the touched lines
(use-package ws-butler
  :ensure t
  :defer t
  :diminish t
  :init
  (ws-butler-global-mode)
  :config
  (diminish 'ws-butler-mode)
  )

(use-package whitespace
  :defer t
  :diminish t
  :init
  (setq whitespace-line-column nil
        whitespace-style '(face trailing lines-tail space-before-tab newline
                                indentation empty space-after-tab))
)


(use-package proced
  :defer t
  :init
  :config
  (add-hook 'proced-mode-hook '(lambda ()
                                 (proced-toggle-auto-update 1)))
)

(use-package erc
  :ensure t
  :disabled t
  :init
  (require 'tls)
  (erc-tls
   :server "irc.freenode.net"
   :port 6667 ;6697
   :nick "zimoun"
   )
  (setq erc-nick "zimoun")
  (setq erc-join-channels-alist '(("freenode.net" "#guix")))
)

;;; convert ^L (C-q l) to pretty lines
(use-package page-break-lines
  :ensure t
  :defer
  :init
  ;; (turn-on-page-break-lines-mode)
  (page-break-lines-mode 1)
  (diminish 'page-break-lines-mode)
)

;;; JavaScript utility
;;; https://github.com/skeeto/skewer-mode
(use-package skewer-mode
  :ensure t
  :disabled t
  )

(provide 'my-pkg)