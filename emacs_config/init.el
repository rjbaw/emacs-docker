(setq inhibit-startup-message t)
(setq visible-bell 1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(global-hl-line-mode t)
(line-number-mode t)
(visual-line-mode t)
;(setq indent-tabs-mode t)
(setq-default indent-tabs-mode nil)

(setq default-frame-alist '((font . "DM Mono")))
(setq custom-file "~/.emacs.d/custom-file.el")
;(load-file custom-file)

(setq exec-path (append exec-path '("/usr/bin")))

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
(require 'quelpa-use-package)
;(setq use-package-ensure-function 'quelpa)
(setq use-package-always-ensure t)

(use-package spinner
	     :quelpa (spinner
		       :fetcher github
		       :repo "Malabarba/spinner.el"))
(use-package undo-fu)
(use-package evil
	     :ensure t
	     :init
             (setq evil-undo-system 'undo-fu)
             (setq evil-want-integration t)
             (setq evil-want-keybinding nil)
             :config
	     (evil-mode t))
(use-package evil-collection
	     :after evil
	     :config
	     (evil-collection-init)
	     :ensure t)

(use-package org
	     :ensure t)
(setq org-confirm-babel-evaluate nil)
(setq org-pretty-entities t)
(setq org-hide-emphasis-markers t)
(setq org-adapt-indentation nil)
;(setq org-export-babel-evaluate nil)
; imagemagick, dvipng, dvisvgm
(setq org-preview-latex-default-process 'imagemagick)
(setq org-latex-inputenc-alist '(("utf8")))
(setq org-latex-minted-options '(("breaklines" "true")
                                 ("breakanywhere" "true")))
(setq org-latex-listings 'minted)
(setq org-latex-packages-alist '(("" "minted" t)
                                 ("" "tcolorbox" t))) ;unicode-math
; Backends: pdflatex, xelatex, lualatex
(setq org-latex-pdf-process
      '("lualatex -shell-escape -interaction nonstopmode -output-directory %o %f"
        "lualatex -shell-escape -interaction nonstopmode -output-directory %o %f"
        "lualatex -shell-escape -interaction nonstopmode -output-directory %o %f"))
(font-lock-add-keywords 'org-mode
                        '(("^ *\\([-]\\) "
                           (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))
(setq org-preview-latex-process-alist
       '((dvipng :programs
         ("lualatex" "dvipng")
         :description "dvi > png" :message "you need to install the programs: latex and dvipng." :image-input-type "dvi" :image-output-type "png" :image-size-adjust
         (1.0 . 1.0)
         :latex-compiler
         ("lualatex -output-format dvi -interaction nonstopmode -output-directory %o %f")
         :image-converter
         ("dvipng -fg %F -bg %B -D %D -T tight -o %O %f"))
       (dvisvgm :programs
          ("lualatex" "dvisvgm")
          :description "dvi > svg" :message "you need to install the programs: latex and dvisvgm." :use-xcolor t :image-input-type "xdv" :image-output-type "svg" :image-size-adjust
          (3 . 1.5)
          :latex-compiler
          ("lualatex -no-pdf -interaction nonstopmode -output-directory %o %f")
          :image-converter
          ("dvisvgm %f -n -b min -c %S -o %O"))
       (imagemagick :programs
              ("lualatex" "convert")
              :description "pdf > png" :message "you need to install the programs: latex and imagemagick." :use-xcolor t :image-input-type "pdf" :image-output-type "png" :image-size-adjust
              (1.0 . 1.0)
              :latex-compiler
              ("lualatex -no-pdf -interaction nonstopmode -output-directory %o %f")
              :image-converter
              ("convert -density %D -trim -antialias %f -quality 100 %O"))))
(add-hook 'org-babel-after-execute-hook 'org-display-inline-images)
(add-hook 'org-mode-hook 'org-display-inline-images)
(setq org-format-latex-options (plist-put org-format-latex-options :scale 2.0))
(add-hook 'LaTeX-mode-hook 'turn-on-reftex)

(when (version<= "9.2" (org-version))
  (require 'org-tempo))
(use-package org-ref)
(use-package org-bullets
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))
(setq org-src-preserve-indentation t
      org-src-tab-acts-natively t
      org-edit-src-content-indentation 0)
(use-package spacemacs-common
    :ensure spacemacs-theme
    :config (load-theme 'spacemacs-dark t))

;(use-package undo-tree
;    :quelpa (undo-tree
;            :fetcher git
;            :url "http://www.dr-qubit.org/undo-tree/undo-tree.el"))
;(add-hook 'evil-local-mode-hook 'turn-on-undo-tree-mode)

(use-package magit
	     :ensure t)
(use-package lsp-ui
	     :quelpa (lsp-ui
		       :fetcher github
		       :repo "emacs-lsp/lsp-ui")
	     :config
	     (lsp-ui-peek-enable 1)
;	     (lsp-ui-peek-show-directory 1)
	     (lsp-ui-doc-enable 1)
	     :commands lsp-ui-mode)
(use-package helm-lsp
	     :ensure t
	     :commands helm-lsp-workspace-symbol)
(use-package lsp-treemacs
	     :quelpa (lsp-treemacs
		       :fetcher github
		       :repo "emacs-lsp/lsp-treemacs")
	     :commands lsp-treemacs-errors-list)
	     :init (lsp-treemacs-sync-mode 1)
(use-package dap-mode
	     :ensure t)
(use-package which-key
	     :config
	     (which-key-mode))
(use-package company
	     :config
	     (setq company-idle-delay 0.0)
	     (setq company-minimum-prefix-length 1)
	     (global-company-mode t))
(use-package company-math)
(add-to-list 'company-backends 'company-math-symbols-unicode)
(use-package auctex
  :defer t)
(use-package yasnippet
  :ensure t)
(use-package yasnippet-snippets
  :ensure t)
(yas-global-mode 1)
(use-package flycheck)
(use-package spaceline
  :demand t
  :init
  (setq powerline-default-separator 'arrow-fade)
  :config
  (require 'spaceline-config)
  (spaceline-spacemacs-theme))
(use-package smartparens
	    :config (smartparens-global-mode t))
;(electric-pair-mode t)
(use-package highlight-indent-guides
  :config
  (add-hook 'prog-mode-hook 'highlight-indent-guides-mode)
  (setq highlight-indent-guides-method 'character))
(use-package jupyter)
(use-package ess)
(use-package julia-mode)
(use-package rust-mode)
(use-package org-download)
(setq-default org-download-screenshot-method "scrot -s %s")
(add-hook 'dired-mode-hook 'org-download-enable)
(use-package vimish-fold
  :ensure t
  :after evil)
(use-package evil-vimish-fold
  :ensure t
  :after vimish-fold
  :hook ((prog-mode conf-mode text-mode) . evil-vimish-fold-mode))
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
;   (julia . t)
   (latex . t)
   (shell . t)
   (python . t)
   (jupyter . t)
   ))
;(setq org-babel-defaults-header-args:jupyter-julia '((:async . "yes")
;						     (:session . "jl")
;						     (:kernel . "julia")))
(use-package ob-async)
(setq ob-async-no-async-languages-alist '("jupyter-python" "jupyter-julia"))
(add-hook 'ob-async-pre-execute-src-block-hook
	  '(lambda ()
	     (setq inferior-julia-program-name "/usr/bin/julia")))
(quelpa
  '(lsp-julia
     :fetcher github
     :repo "gdkrmr/lsp-julia"
     :files (:defaults "languageserver")))
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
             :ensure t)
(define-key lsp-mode-map [remap xref-find-apropos] #'helm-lsp-workspace-symbol)
(add-hook 'dap-stopped-hook
	  (lambda (arg) (call-interactively #'dap-hydra)))
(setq dap-auto-configure-features '(sessions locals controls tooltip))
(with-eval-after-load 'lsp-mode
  (setq lsp-diagnostics-modeline-scope :project)
  (add-hook 'lsp-managed-mode-hook 'lsp-diagnostics-modeline-mode))

(use-package lsp-pyright
  :ensure t
  :after lsp-mode
  :hook (python-mode . (lambda ()
                          (require 'lsp-pyright)
                          (lsp))))

; Code from John Kitchin
; https://kitchingroup.cheme.cmu.edu/blog/category/emacs/
(defvar org-latex-fragment-last nil
  "Holds last fragment/environment you were on.")
(defun my/org-latex-fragment--get-current-latex-fragment ()
  "Return the overlay associated with the image under point."
  (car (--select (eq (overlay-get it 'org-overlay-type) 'org-latex-overlay) (overlays-at (point)))))
(defun my/org-in-latex-fragment-p ()
    "Return the point where the latex fragment begins, if inside
  a latex fragment. Else return false"
    (let* ((el (org-element-context))
           (el-type (car el)))
      (and (or (eq 'latex-fragment el-type) (eq 'latex-environment el-type))
          (org-element-property :begin el))))
(defun org-latex-fragment-toggle-auto ()
  ;; Wait for the s
  (interactive)
  (while-no-input 
    (run-with-idle-timer 0.05 nil 'org-latex-fragment-toggle-helper)))
(defun org-latex-fragment-toggle-helper ()
    "Toggle a latex fragment image "
    (condition-case nil
        (and (eq 'org-mode major-mode)
             (let* ((begin (my/org-in-latex-fragment-p)))
               (cond
                ;; were on a fragment and now on a new fragment
                ((and
                  ;; fragment we were on
                  org-latex-fragment-last
                  ;; and are on a fragment now
                  begin
                  ;; but not on the last one this is a little tricky. as you edit the
                  ;; fragment, it is not equal to the last one. We use the begin
                  ;; property which is less likely to change for the comparison.
                  (not (= begin
                          org-latex-fragment-last)))
                 ;; go back to last one and put image back
                 (save-excursion
                   (goto-char org-latex-fragment-last)
                   (when (my/org-in-latex-fragment-p) (org-latex-preview))
                   ;; now remove current imagea
                   (goto-char begin)
                   (let ((ov (my/org-latex-fragment--get-current-latex-fragment)))
                     (when ov
                       (delete-overlay ov)))
                   ;; and save new fragment
                   (setq org-latex-fragment-last begin)))
                
                ;; were on a fragment and now are not on a fragment
                ((and
                  ;; not on a fragment now
                  (not begin)
                  ;; but we were on one
                  org-latex-fragment-last)
                 ;; put image back on
                 (save-excursion
                   (goto-char org-latex-fragment-last)
                   (when (my/org-in-latex-fragment-p)(org-latex-preview)))
                 
                 ;; unset last fragment
                 (setq org-latex-fragment-last nil))
                
                ;; were not on a fragment, and now are
                ((and
                  ;; we were not one one
                  (not org-latex-fragment-last)
                  ;; but now we are
                  begin)
                 (save-excursion
                   (goto-char begin)
                   ;; remove image
                   (let ((ov (my/org-latex-fragment--get-current-latex-fragment)))
                     (when ov
                       (delete-overlay ov)))
                   (setq org-latex-fragment-last begin)))
                ;; else not on a fragment
                ((not begin)
                 (setq org-latex-fragment-last nil)))))
      (error nil)))
(add-hook 'post-command-hook 'org-latex-fragment-toggle-auto)
(setq org-latex-fragment-toggle-helper (byte-compile 'org-latex-fragment-toggle-helper))
(setq org-latex-fragment-toggle-auto (byte-compile 'org-latex-fragment-toggle-auto))
