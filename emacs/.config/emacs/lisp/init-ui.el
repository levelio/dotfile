;;; init-ui.el --- Theme and visual configuration -*- lexical-binding: t; -*-

;;; Code:

(defun zhq/font-available-p (font)
  "Return non-nil if FONT is available."
  (and (display-graphic-p)
       (find-font (font-spec :family font))))

(defun zhq/first-available-font (&rest fonts)
  "Return the first installed font from FONTS."
  (seq-find #'zhq/font-available-p fonts))

(defun zhq/setup-ui ()
  "Apply UI defaults after the first frame exists."
  (when (display-graphic-p)
    (let ((mono-font (zhq/first-available-font
                      "Maple Mono NF CN"
                      "JetBrainsMono Nerd Font Mono"
                      "JetBrains Mono"
                      "Menlo")))
      (when mono-font
        (set-face-attribute 'default nil
                            :family mono-font
                            :height 150
                            :weight 'regular)
        (set-face-attribute 'fixed-pitch nil
                            :family mono-font
                            :height 150)
        (set-face-attribute 'variable-pitch nil
                            :family "SF Pro Text"
                            :height 150))
      (setq-default line-spacing 0.14)
      (setq-default cursor-type 'bar)
      (blink-cursor-mode -1)
      (set-fringe-mode 10)
      (setq window-divider-default-right-width 1
            window-divider-default-bottom-width 1)
      (window-divider-mode 1))))

(defun zhq/tune-faces ()
  "Tune faces after the theme has loaded."
  (set-face-attribute 'line-number nil
                      :foreground "#585b70"
                      :background 'unspecified)
  (set-face-attribute 'line-number-current-line nil
                      :foreground "#cdd6f4"
                      :background 'unspecified
                      :weight 'medium)
  (set-face-attribute 'hl-line nil
                      :background "#1e1e2e")
  (set-face-attribute 'region nil
                      :background "#45475a")
  (set-face-attribute 'fringe nil
                      :background 'unspecified)
  (set-face-attribute 'vertical-border nil
                      :foreground "#313244")
  (set-face-attribute 'window-divider nil
                      :foreground "#313244")
  (set-face-attribute 'mode-line nil
                      :background "#313244"
                      :foreground "#cdd6f4"
                      :box nil)
  (set-face-attribute 'mode-line-inactive nil
                      :background "#181825"
                      :foreground "#6c7086"
                      :box nil)
  (set-face-attribute 'minibuffer-prompt nil
                      :foreground "#89b4fa"
                      :weight 'semibold))

(add-hook 'after-init-hook #'zhq/setup-ui)

(use-package catppuccin-theme
  :demand t
  :custom
  (catppuccin-flavor 'mocha)
  :config
  (load-theme 'catppuccin t)
  (zhq/tune-faces))

(unless noninteractive
  (use-package nerd-icons
    :commands (nerd-icons-icon-for-file
               nerd-icons-icon-for-mode))

  (use-package doom-modeline
    :hook (after-init . doom-modeline-mode)
    :custom
    (doom-modeline-height 32)
    (doom-modeline-bar-width 4)
    (doom-modeline-icon t)
    (doom-modeline-major-mode-icon t)
    (doom-modeline-buffer-file-name-style 'truncate-with-project)
    (doom-modeline-buffer-encoding nil)
    (doom-modeline-indent-info nil)
    (doom-modeline-check-simple-format t)
    (doom-modeline-vcs-max-length 28)
    (doom-modeline-minor-modes nil))

  (use-package solaire-mode
    :hook (after-init . solaire-global-mode))

  (use-package dashboard
    :custom
    (dashboard-startup-banner 'logo)
    (dashboard-projects-backend 'project-el)
    (dashboard-center-content t)
    (dashboard-vertically-center-content t)
    (dashboard-set-heading-icons t)
    (dashboard-set-file-icons t)
    (dashboard-items '((recents . 8)
                       (projects . 6)
                       (bookmarks . 4)))
    (dashboard-footer-messages
     '("Make it small. Make it yours."))
    :config
    (dashboard-setup-startup-hook))

  (use-package nerd-icons-completion
    :after (marginalia nerd-icons)
    :config
    (nerd-icons-completion-mode 1)
    (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

  (use-package nerd-icons-dired
    :hook (dired-mode . nerd-icons-dired-mode))

  (use-package diff-hl
    :hook ((prog-mode . diff-hl-mode)
           (text-mode . diff-hl-mode)
           (dired-mode . diff-hl-dired-mode))
    :config
    (diff-hl-flydiff-mode 1))

  (use-package hl-todo
    :hook (prog-mode . hl-todo-mode)
    :custom
    (hl-todo-keyword-faces
     '(("TODO" . "#f5c2e7")
       ("FIXME" . "#f38ba8")
       ("HACK" . "#fab387")
       ("REVIEW" . "#89b4fa")
       ("NOTE" . "#94e2d5")
       ("DEPRECATED" . "#f38ba8")))))

(provide 'init-ui)

;;; init-ui.el ends here
