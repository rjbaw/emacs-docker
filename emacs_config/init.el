;;; Emacs Config Init File
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

(global-hl-line-mode 1)
(global-display-line-numbers-mode 1)
(global-visual-line-mode 1)
(setq-default indent-tabs-mode nil)

(setq inhibit-startup-message t
      visible-bell t
      c-default-style "linux"
      c-basic-offset 4
      native-comp-async-report-warnings-errors nil
      default-frame-alist '((font . "DM Mono"))
      custom-file "~/.emacs.d/custom-file.el")

(setq gc-cons-threshold (* 100 1024 1024)
      read-process-output-max (* 1024 1024))

(when (file-exists-p custom-file)
  (load custom-file 'noerror 'nomessage))
(add-to-list 'exec-path "/usr/bin")

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives
             '("gnu" . "https://elpa.gnu.org/packages/") t)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))
(setq use-package-always-ensure t)

(use-package auto-package-update
  :config
  (auto-package-update-maybe))

(use-package undo-tree
  :config
  (global-undo-tree-mode)
  (global-set-key (kbd "C-x u") 'undo-tree-visualize)
  (setq undo-tree-history-directory-alist `(("." . ,(expand-file-name "undo" user-emacs-directory)))))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-undo-system 'undo-tree)
  (setq evil-want-C-u-scroll t)
  (setq evil-esc-delay 0)
  :config
  (evil-mode t)
  (define-key evil-normal-state-map "\C-v" 'evil-visual-block)
  (define-key evil-normal-state-map "u" 'undo-tree-undo)
  (define-key evil-normal-state-map (kbd "C-r") 'undo-tree-redo))

(use-package evil-surround
  :after evil
  :config
  (global-evil-surround-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package vimish-fold)

(use-package evil-vimish-fold
  :after vimish-fold
  :hook
  ((prog-mode conf-mode text-mode) . evil-vimish-fold-mode))

(use-package key-chord
  :config
  (key-chord-define evil-insert-state-map "yy" 'evil-normal-state)
  (key-chord-mode 1))

(use-package sqlite3
  :defer t)

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
  (setq org-hide-emphasis-markers t)
  (setq org-adapt-indentation nil)
  (setq org-image-actual-width nil)
  (setq org-pretty-entities nil)
  ;; (setq org-export-babel-evaluate nil)
  (setq org-preview-latex-default-process 'imagemagick)
  (setq org-latex-inputenc-alist '(("utf8" . "inputenc")))
  (setq org-latex-minted-options '(("breaklines" "true")
                                   ("breakanywhere" "true")))
  (setq org-latex-listings 'minted)
  (setq org-latex-packages-alist '(("" "minted" t)
                                   ("" "tcolorbox" t))) ;unicode-math
  (setq org-latex-pdf-process
        '("latexmk -pdf -pdflatex='lualatex -shell-escape -interaction nonstopmode' -output-directory=%o %f"))
  (setq org-preview-latex-process-alist
        '((imagemagick :programs ("lualatex" "convert")
                       :description "pdf > png"
                       :message "you need to install the programs: lualatex and imagemagick."
                       :use-xcolor t
                       :image-input-type "pdf"
                       :image-output-type "png"
                       :image-size-adjust (1.0 . 1.0)
                       :latex-compiler ("lualatex -interaction nonstopmode -output-directory %o %f")
                       :image-converter ("convert -density %D -trim -antialias %f -quality 100 %O"))))
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 ()
                                  (compose-region (match-beginning 1) (match-end 1) "•"))))))
  (setq org-format-latex-options (plist-put org-format-latex-options :scale 1.5))
  (setq org-agenda-files '("~/org"))
  (setq org-agenda-span 7)
  (setq org-roam-directory "~/org-roam")
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (latex . t)
     (python . t)
     (jupyter . t)))
  :ensure t)

(when (version<= "9.2" (org-version))
  (require 'org-tempo))

(use-package org-ref)

(use-package org-bullets
  :hook (org-mode . org-bullets-mode))

(use-package org-download
  :hook ((dired-mode . org-download-enable)
         (org-mode . org-download-enable))
  :config
  (setq-default org-download-screenshot-method "scrot -s %s"))

(use-package org-fragtog)

(use-package spacemacs-theme
  :config
  (load-theme 'spacemacs-dark t))

(use-package spaceline
  :demand t
  :init
  (setq powerline-default-separator 'arrow-fade)
  :config
  (require 'spaceline-config)
  (spaceline-spacemacs-theme))

(use-package magit
  :config
  (setq magit-status-buffer-switch-function 'switch-to-buffer))

(use-package git-gutter
  :config
  (global-git-gutter-mode +1))

(use-package spinner)
(use-package vterm)
(use-package markdown-mode)
(use-package cuda-mode)
(use-package clang-format)
(use-package pdf-tools)

(use-package format-all
  :commands format-all-mode
  :hook ((prog-mode . (lambda ()
                        (format-all-mode)
                        (format-all-ensure-formatter)))
         (c++-mode . (lambda ()
                       (format-all-mode)
                       (format-all-ensure-formatter)))))

(use-package company
  :config
  (setq company-idle-delay 0.0)
  (setq company-minimum-prefix-length 1)
  (setq company-selection-wrap-around t)
  (add-to-list 'company-backends 'company-capf)
  (define-key company-mode-map [remap indent-for-tab-command]
	      #'company-indent-or-complete-common)
  (global-company-mode t))

(use-package company-math
  :config
  (add-to-list 'company-backends 'company-math-symbols-unicode))

;; (use-package smartparens
;;   :config (smartparens-global-mode t))
;; (electric-pair-mode t)

(use-package yasnippet
  :config
  (yas-global-mode 1))

(use-package yasnippet-snippets)

(use-package auctex
  :init
  (unless (fboundp 'TeX-latex-mode) (defalias 'TeX-latex-mode 'latex-mode))
  (setq-default TeX-engine 'luatex)
  (setq-default preview-scale-function 1.5)
  :hook
  ((LaTeX-mode) . texfrag-auto-mode))

(use-package auctex-latexmk
  :after auctex
  :config
  (auctex-latexmk-setup))

(use-package jupyter)
(use-package ess)
(use-package ein)
(use-package julia-mode)
(use-package yaml-mode)
(use-package matlab-mode)
(use-package docker)
(use-package dockerfile-mode)
(use-package docker-compose-mode)
(use-package rust-mode)

(use-package ob-async
  :config
  (setq ob-async-no-async-languages-alist '("jupyter-python" "jupyter-julia"))
  (add-hook 'ob-async-pre-execute-src-block-hook
            '(lambda ()
               (setq inferior-julia-program-name "/usr/bin/julia"))))

(use-package which-key
  :config
  (which-key-mode))

(use-package lsp-mode
  :init (setq lsp-keymap-prefix "C-c l")
  :hook ((prog-mode . lsp-deferred)
         (lsp-mode . lsp-enable-which-key-integration)
         (lsp-managed-mode . lsp-modeline-diagnostics-mode))
  :commands (lsp lsp-deferred)
  :config
  (setq lsp-diagnostics-modeline-scope :project)
  (setq lsp-warn-no-matched-clients nil)
  (setq lsp-enable-suggest-server-download t)
  (setq lsp-auto-install-server t)
  (setq lsp-idle-delay 0.1)
  (setq lsp-completion-provider :capf)
  (setq lsp-inlay-hint-enable t
        lsp-inlay-hint-show-parameter-names t
        lsp-inlay-hint-show-variable-name t
	lsp-inlay-hint-show-constructor-arguments t)
  (setq lsp-clients-clangd-args
	'("--background-index"
	  "--header-insertion=never"
	  "--header-insertion-decorators=0"
	  ))
  (add-to-list 'company-backends 'company-capf)
  (define-key lsp-mode-map (kbd "TAB") 'company-complete-selection)
  (define-key lsp-mode-map [remap xref-find-apropos] #'helm-lsp-workspace-symbol)
  )

(use-package lsp-ui
  :commands lsp-ui-mode
  :after lsp-mode
  :init
  (setq lsp-ui-doc-enable t)
  (setq lsp-ui-peek-enable t)
  (setq lsp-ui-peek-show-directory t))

(use-package helm
  :init
  (helm-mode 1)
  :bind
  (:map global-map
        ([remap find-file] . helm-find-files)
        ([remap execute-extended-command] . helm-M-x)
        ([remap switch-to-buffer] . helm-mini))
  :config
  (setq helm-M-x-fuzzy-match t)
  (setq helm-recentf-fuzzy-match t)
  (helm-mode 1))

(use-package helm-lsp
  :after lsp-mode
  :commands helm-lsp-workspace-symbol
  :config
  (setq helm-lsp-sources '(helm-lsp-source-symbol helm-lsp-source-type))
  :bind (("M-." . helm-lsp-find-definition)
	 ("M-," . helm-lsp-find-references)))

(use-package projectile
  :config
  (projectile-mode +1)
  (setq projectile-completion-system 'helm))

(use-package helm-projectile
  :after (helm projectile)
  :config
  (helm-projectile-on))

(use-package hydra)

(use-package treemacs
  :custom
  (treemacs-space-between-root-nodes nil))

(use-package lsp-treemacs
  :commands
  (lsp-treemacs-errors-list)
  :init
  (lsp-treemacs-sync-mode 1))

(use-package flycheck
  :config
  (global-flycheck-mode 1))

(use-package flyspell
  :config
  (setq ispell-program-name "hunspell")
  (setq ispell-dictionary "en_US")
  :hook ((text-mode . flyspell-mode)
         (prog-mode . flyspell-prog-mode)))

(use-package dap-mode
  :config
  (require 'dap-lldb)
  (require 'dap-gdb-lldb)
  (dap-auto-configure-mode 1)
  )
(use-package dap-mode
  :after lsp-mode
  :config
  (dap-ui-mode 1)
  (dap-tooltip-mode 1)
  (tooltip-mode 1)
  (require 'dap-ui)
  (dap-ui-controls-mode 1)
  (require 'dap-lldb)
  (dap-register-debug-template
   "C++ LLDB"
   (list :type "lldb"
         :request "launch"
         :name "LLDB::Run"
         :gdbpath "lldb"
         :target nil
         :cwd nil))
  (dap-auto-configure-mode 1))


(use-package cmake-mode)

(use-package cmake-ide
  :config
  (cmake-ide-setup))

(use-package avy)

(use-package helm-xref)

(use-package lsp-pyright
  :after lsp-mode
  :hook (python-mode . (lambda () (require 'lsp-pyright) (lsp)))
  :config (setq lsp-pyright-venv-path "/opt/emacs/"))

(use-package tree-sitter
  :config
  (setq treesit-language-source-alist
	'((c   "https://github.com/tree-sitter/tree-sitter-c")
	  (cpp "https://github.com/tree-sitter/tree-sitter-cpp")))
  (global-tree-sitter-mode 1))

(use-package texfrag
  :init
  (setq texfrag-scale 1.2)
  :config
  (texfrag-global-mode 1))

(defvar texfrag-auto-mode nil)
(defun texfrag-auto--evaluate-function ()
  (when texfrag-auto-mode
    (unless (texfrag-auto--process-running-p "Preview-LaTeX")
      (preview-buffer))))
(defun texfrag-auto--process-running-p (process-name)
  (seq-some (lambda (proc)
              (and (string= (process-name proc) process-name)
                   (process-live-p proc)))
            (process-list)))
(defun texfrag-auto--after-save ()
  (when texfrag-auto-mode
    (condition-case err
        (texfrag-auto--evaluate-function)
      (error (message "Error in texfrag-auto mode: %s" err)))))
(define-minor-mode texfrag-auto-mode
  "TexFrag-Auto"
  :lighter " TexFrag-Auto"
  :init-value nil
  :global nil
  :group 'org
  (if texfrag-auto-mode
      (add-hook 'after-save-hook 'texfrag-auto--after-save nil 'local)
    (remove-hook 'after-save-hook 'texfrag-auto--after-save 'local)))

(when (fboundp 'treesit-install-language-grammar)
  (unless (treesit-language-available-p 'c)
    (treesit-install-language-grammar 'c))
  (unless (treesit-language-available-p 'cpp)
    (treesit-install-language-grammar 'cpp)))
