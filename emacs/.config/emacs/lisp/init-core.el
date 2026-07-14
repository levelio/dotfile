;;; init-core.el --- Core settings and project commands -*- lexical-binding: t; -*-

;;; Code:

(require 'cl-lib)
(require 'json)
(require 'seq)
(require 'subr-x)

(setq user-full-name "Zhiqiang He")

(when (eq system-type 'darwin)
  (setq mac-command-modifier 'super
        mac-option-modifier 'meta
        mac-right-option-modifier 'none))

(global-set-key (kbd "<escape>") #'keyboard-escape-quit)

(savehist-mode 1)
(save-place-mode 1)
(recentf-mode 1)
(global-auto-revert-mode 1)
(electric-pair-mode 1)
(column-number-mode 1)
(global-display-line-numbers-mode 1)
(pixel-scroll-precision-mode 1)
(global-visual-line-mode -1)
(global-hl-line-mode 1)

(dolist (hook '(org-mode-hook
                markdown-mode-hook
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook))
  (add-hook hook (lambda () (display-line-numbers-mode -1))))

(setq-default line-spacing 0.08)
(setq frame-resize-pixelwise t)
(setq-default cursor-in-non-selected-windows nil)

(use-package which-key
  :ensure nil
  :hook (after-init . which-key-mode)
  :custom
  (which-key-idle-delay 0.35)
  (which-key-idle-secondary-delay 0.05)
  (which-key-separator "  ")
  (which-key-prefix-prefix "+"))

(use-package project
  :ensure nil
  :custom
  (project-switch-commands
   '((project-find-file "Find file")
     (project-find-regexp "Search")
     (project-dired "Dired")
     (project-eshell "Eshell"))))

(defun zhq/open-emacs-config ()
  "Open this Emacs configuration directory."
  (interactive)
  (dired minimal-emacs-user-directory))

(defun zhq/find-dotfiles ()
  "Open the dotfiles repository."
  (interactive)
  (dired (expand-file-name "~/dotfiles/")))

(defun zhq/project-root ()
  "Return the current project root, or `default-directory'."
  (if-let ((project (project-current nil)))
      (project-root project)
    default-directory))

(defun zhq/project-package-manager (&optional root)
  "Return the JavaScript package manager for ROOT."
  (let ((root (or root (zhq/project-root))))
    (cond
     ((file-exists-p (expand-file-name "pnpm-lock.yaml" root)) "pnpm")
     ((file-exists-p (expand-file-name "yarn.lock" root)) "yarn")
     ((file-exists-p (expand-file-name "bun.lockb" root)) "bun")
     ((file-exists-p (expand-file-name "package-lock.json" root)) "npm")
     (t "pnpm"))))

(defun zhq/project-package-scripts (&optional root)
  "Return package.json script names for ROOT."
  (let* ((root (or root (zhq/project-root)))
         (package-json (expand-file-name "package.json" root)))
    (when (file-exists-p package-json)
      (let* ((package (json-parse-file package-json
                                       :object-type 'hash-table
                                       :array-type 'list))
             (scripts (gethash "scripts" package)))
        (when (hash-table-p scripts)
          (sort (hash-table-keys scripts) #'string<))))))

(defun zhq/project-run-package-script ()
  "Run a package.json script from the current project."
  (interactive)
  (let* ((root (zhq/project-root))
         (scripts (zhq/project-package-scripts root)))
    (unless scripts
      (user-error "No package.json scripts found"))
    (let* ((script (completing-read "Script: " scripts nil t))
           (manager (zhq/project-package-manager root))
           (default-directory root))
      (compile (format "%s run %s" manager script)))))

(defun zhq/project-run-package-script-if-present (script)
  "Run package.json SCRIPT from the current project."
  (let* ((root (zhq/project-root))
         (scripts (zhq/project-package-scripts root)))
    (unless (member script scripts)
      (user-error "No package.json script named %s" script))
    (let ((default-directory root))
      (compile (format "%s run %s" (zhq/project-package-manager root) script)))))

(defun zhq/project-dev ()
  "Run the current project's dev script."
  (interactive)
  (zhq/project-run-package-script-if-present "dev"))

(defun zhq/project-test ()
  "Run the current project's test script."
  (interactive)
  (zhq/project-run-package-script-if-present "test"))

(defun zhq/comment-line-or-region ()
  "Comment or uncomment the active region, or the current line."
  (interactive)
  (if (use-region-p)
      (comment-or-uncomment-region (region-beginning) (region-end))
    (comment-line 1)))

(defun zhq/flymake-show-buffer-diagnostics ()
  "Show diagnostics for the current buffer."
  (interactive)
  (require 'flymake)
  (flymake-show-buffer-diagnostics))

(defun zhq/flymake-show-project-diagnostics ()
  "Show diagnostics for the current project."
  (interactive)
  (require 'flymake)
  (flymake-show-project-diagnostics))

(defun zhq/flymake-show-diagnostic ()
  "Show the diagnostic at point."
  (interactive)
  (require 'flymake)
  (flymake-show-diagnostic (point)))

(defun zhq/flymake-goto-next-error ()
  "Go to the next Flymake diagnostic."
  (interactive)
  (require 'flymake)
  (flymake-goto-next-error))

(defun zhq/flymake-goto-prev-error ()
  "Go to the previous Flymake diagnostic."
  (interactive)
  (require 'flymake)
  (flymake-goto-prev-error))

(provide 'init-core)

;;; init-core.el ends here
