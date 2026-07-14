;;; pre-early-init.el --- Local early settings -*- no-byte-compile: t; lexical-binding: t; -*-

;;; Code:

;; Keep the source-controlled config clean when ~/.config/emacs is stowed.
(defconst zhq/emacs-state-directory
  (expand-file-name "emacs/"
                    (or (getenv "XDG_STATE_HOME")
                        (expand-file-name ".local/state/" "~"))))

(make-directory zhq/emacs-state-directory t)

(setq user-emacs-directory (file-name-as-directory zhq/emacs-state-directory)
      package-user-dir (expand-file-name "elpa/" user-emacs-directory))

(setq minimal-emacs-frame-title-format "%b - Emacs"
      minimal-emacs-gc-cons-threshold (* 64 1024 1024)
      minimal-emacs-ui-features '(context-menu tooltips))

(when noninteractive
  (setq minimal-emacs-package-initialize-and-refresh nil))

;;; pre-early-init.el ends here
