(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(global-hl-line-mode 1)
(line-number-mode 1)
(visual-line-mode 1)

(setq inhibit-startup-message t
      visible-bell t
      c-default-style "linux"
      c-basic-offset 4
      default-frame-alist '((font . "DM Mono"))
      custom-file "~/.emacs.d/custom-file.el"
      native-comp-async-report-warnings-errors nil
      exec-path (append exec-path '("/usr/bin"))
      )

(setq-default indent-tabs-mode nil)

(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives
	     '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(add-to-list 'package-archives
	     '("org" . "https://orgmode.org/elpa/") t)
(add-to-list 'package-archives
	     '("gnu" . "https://elpa.gnu.org/packages/") t)
(package-initialize)
(package-refresh-contents)

;(unless (package-installed-p 'use-package)
;  (package-refresh-contents)
;  (package-install 'use-package))
;(eval-when-compile
;  (require 'use-package))
(unless (package-installed-p 'quelpa)
  (with-temp-buffer
    (url-insert-file-contents "https://github.com/quelpa/quelpa/raw/master/quelpa.el")
    (eval-buffer)
    (quelpa-self-upgrade)))
(quelpa
 '(quelpa-use-package
   :fetcher git
   :url "https://github.com/quelpa/quelpa-use-package.git"))
(quelpa
 '(lsp-julia
   :fetcher github
   :repo "gdkrmr/lsp-julia"
   :files (:defaults "languageserver")))
(require 'quelpa-use-package)
;(setq use-package-ensure-function 'quelpa)
(setq use-package-always-ensure t)

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-undo-system 'undo-redo)
  (setq evil-want-C-u-scroll t)
  (setq evil-esc-delay 0)
  :config
  (define-key evil-normal-state-map "\C-v" 'evil-visual-block)
  (evil-mode t)
  :ensure t)

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init)
  :ensure t)

(use-package vimish-fold
  :ensure t
  :after evil)

(use-package evil-vimish-fold
  :ensure t
  :after vimish-fold
  :hook
  ((prog-mode conf-mode text-mode) . evil-vimish-fold-mode)
  )

(use-package key-chord
  :config
  (key-chord-define evil-insert-state-map "yy" 'evil-normal-state)
  (key-chord-mode t)
  :ensure t)

(use-package spinner
  :quelpa
  (spinner
   :fetcher github
   :repo "Malabarba/spinner.el")
  )

(use-package vterm
  :ensure t)

(use-package org
  :hook
  ((org-mode . texfrag-auto-mode)
   (org-mode . org-download-enable)
   (org-mode . org-display-inline-images)
   (org-babel-after-execute . org-display-inline-images)
   (LaTeX-mode . turn-on-reftex))
  :config
  (setq org-src-preserve-indentation t)
  (setq org-src-tab-acts-natively t)
  (setq org-edit-src-content-indentation 0)
  (setq org-confirm-babel-evaluate nil)
  (setq org-pretty-entities t)
  (setq org-hide-emphasis-markers t)
  (setq org-adapt-indentation nil)
  (setq org-image-actual-width nil)
;(setq org-export-babel-evaluate nil)
; imagemagick(lualatex only), dvipng(unicode not supported), dvisvgm(xelatex only)
  (setq org-preview-latex-default-process 'imagemagick)
  (setq org-latex-inputenc-alist '(("utf8")))
  (setq org-latex-minted-options '(("breaklines" "true")
				   ("breakanywhere" "true")))
  (setq org-latex-listings 'minted)
  (setq org-latex-packages-alist '(("" "minted" t)
				   ("" "tcolorbox" t))) ;unicode-math
					; Backends: pdflatex, xelatex, lualatex (Specify in LATEX_COMPILER)
  (setq org-latex-pdf-process
	'("latexmk -pdflatex='%latex -shell-escape -interaction nonstopmode' -pdf -output-directory=%o %f"))
  (setq org-preview-latex-process-alist
	'((dvipng :programs ("latex" "dvipng")
		  :description "dvi > png"
		  :message "you need to install the programs: latex and dvipng."
		  :image-input-type "dvi"
		  :image-output-type "png"
		  :image-size-adjust (1.0 . 1.0)
		  :latex-compiler ("latex -interaction nonstopmode -output-directory %o %f")
		  :image-converter ("dvipng -D %D -T tight -o %O %f"))
	  (dvisvgm :programs ("latex" "dvisvgm")
		   :description "dvi > svg"
		   :message "you need to install the programs: latex and dvisvgm."
		   :use-xcolor t
		   :image-input-type "xdv"
		   :image-output-type "svg"
		   :image-size-adjust (1.7 . 1.5)
		   :latex-compiler ("xelatex -no-pdf -interaction nonstopmode -output-directory %o %f")
		   :image-converter ("dvisvgm %f -n -b min -c %S -o %O"))
	  (imagemagick :programs ("latex" "convert")
		       :description "pdf > png"
		       :message "you need to install the programs: latex and imagemagick."
		       :use-xcolor t
		       :image-input-type "pdf"
		       :image-output-type "png"
		       :image-size-adjust (1.0 . 1.0)
		       :latex-compiler ("lualatex -interaction nonstopmode -output-directory %o %f")
		       :image-converter ("convert -density %D -trim -antialias %f -quality 100 %O"))))
  (font-lock-add-keywords 'org-mode '(("^ *\\([-]\\) " (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))
  (setq org-format-latex-options (plist-put org-format-latex-options :scale 1.5))
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
;    (julia . t)
     (latex . t)
     (shell . t)
     (python . t)
     (jupyter . t)))
  :ensure t
  )

(when (version<= "9.2" (org-version))
  (require 'org-tempo))
(use-package org-ref)
(use-package org-bullets
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
  )

(use-package org-fragtog
  :ensure t)

(use-package spacemacs-theme
  :ensure t
  :config
  (load-theme 'spacemacs-dark t))

(use-package magit
  :ensure t)

(use-package lsp-ui
  :quelpa
  (lsp-ui
   :fetcher github
   :repo "emacs-lsp/lsp-ui")
  :config
  (lsp-ui-peek-enable 1)
  (lsp-ui-peek-show-directory 1)
  (lsp-ui-doc-enable 1)
  :commands lsp-ui-mode)

(use-package helm-lsp
  :ensure t
  :commands helm-lsp-workspace-symbol)

(use-package tree-sitter
  :ensure t)

(use-package lsp-treemacs
  :quelpa
  (lsp-treemacs
   :fetcher github
   :repo "emacs-lsp/lsp-treemacs")
  :commands
  (lsp-treemacs-errors-list)
  :init
  (lsp-treemacs-sync-mode 1))

(use-package dap-mode
  :config
  (add-hook 'dap-stopped-hook
	    (lambda (arg) (call-interactively #'dap-hydra)))
  (setq dap-auto-configure-features '(sessions locals controls tooltip))
  :ensure t)

(use-package which-key
  :config
  (which-key-mode))

(use-package company
  :config
  (setq company-idle-delay 0.0)
  (setq company-minimum-prefix-length 1)
  (global-company-mode t))

(use-package company-math
  :config
  (add-to-list 'company-backends 'company-math-symbols-unicode))

(use-package auctex
  :ensure t
  :init
  (unless (fboundp 'TeX-latex-mode) (defalias 'TeX-latex-mode 'latex-mode))
  (setq-default TeX-engine 'luatex)
  (setq-default preview-scale-function 1.5)
  :hook
  ((LaTeX-mode) . texfrag-auto-mode)
  )

(use-package auctex-latexmk
  :ensure t
  :init
  (auctex-latexmk-setup)
  )


(use-package yasnippet
  :config
  (yas-global-mode 1)
  :ensure t)
(use-package yasnippet-snippets
  :ensure t)

(use-package flycheck)

(use-package spaceline
  :demand t
  :init
  (setq powerline-default-separator 'arrow-fade)
  :config
  (require 'spaceline-config)
  (spaceline-spacemacs-theme))

;(use-package smartparens
;  :config (smartparens-global-mode t))
;(electric-pair-mode t)

(use-package highlight-indent-guides
  :config
  (add-hook 'prog-mode-hook 'highlight-indent-guides-mode)
  (setq highlight-indent-guides-method 'character))

(use-package jupyter)
(use-package ess)
(use-package ein)
(use-package julia-mode)
;(use-package matlab-mode)
(use-package rust-mode)
(use-package org-download
  :hook (dired-mode . org-download-enable)
  :config
  (setq-default org-download-screenshot-method "scrot -s %s")
  )

(use-package ob-async
  :config
  (setq ob-async-no-async-languages-alist '("jupyter-python" "jupyter-julia"))
  (add-hook 'ob-async-pre-execute-src-block-hook
	    '(lambda ()
	       (setq inferior-julia-program-name "/usr/bin/julia")))
  )

(use-package lsp-mode
  :init (setq lsp-keymap-prefix "C-c l")
  :hook
  (
   (sh-mode . lsp)
   (python-mode . lsp)
   (julia-mode . lsp)
   (rust-mode . lsp)
   (lsp-mode . lsp-enable-which-key-integration)
   )
  :commands (lsp lsp-deferred)
  :config
  (define-key lsp-mode-map [remap xref-find-apropos] #'helm-lsp-workspace-symbol)

  (with-eval-after-load 'lsp-mode
    (setq lsp-diagnostics-modeline-scope :project)
    (add-hook 'lsp-managed-mode-hook 'lsp-diagnostics-modeline-mode))
  :ensure t)

(use-package lsp-pyright
  :ensure t
  :after lsp-mode
  :hook (python-mode . (lambda () (require 'lsp-pyright) (lsp)))
  :config (setq lsp-pyright-venv-path "/opt/emacs/")
  )

(use-package texfrag
  :init
  (setq texfrag-scale 1.2)
  :ensure t
  :config
  (texfrag-global-mode))

(defvar texfrag-auto-mode nil)
(defun texfrag-auto--evaluate-function ()
  (when texfrag-auto-mode
    (unless (texfrag-auto--process-running-p "Preview-LaTeX")
      (preview-buffer))))
(defun texfrag-auto--process-running-p (process-name)
  (cl-some (lambda (proc)
             (and (string= (process-name proc) process-name)
                  (process-live-p proc)))
           (process-list)))
(defun texfrag-auto--after-save ()
  (when texfrag-auto-mode
    (texfrag-auto--evaluate-function)))
(define-minor-mode texfrag-auto-mode
  "TexFrag-Auto"
  :lighter " TexFrag-Auto"
  :init-value nil
  :global nil
  :group 'org
  (if texfrag-auto-mode
      (add-hook 'after-save-hook 'texfrag-auto--after-save nil 'local)
    (remove-hook 'after-save-hook 'texfrag-auto--after-save 'local)))
