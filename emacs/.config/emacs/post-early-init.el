;;; post-early-init.el --- Local post-early settings -*- no-byte-compile: t; lexical-binding: t; -*-

;;; Code:

;; minimal-emacs.d keeps loading user init files from the stowed source
;; directory, while Emacs runtime files live under `user-emacs-directory`.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

;; GNU/NonGNU ELPA signatures have failed for a few packages on this machine.
;; Prefer MELPA for affected packages while keeping signature verification
;; enabled. UI packages use MELPA Stable where possible so cached archive
;; indexes are less likely to point at expired MELPA snapshot tarballs.
(setq package-pinned-packages
      (append '((add-node-modules-path . "melpa")
                (async . "melpa-stable")
                (catppuccin-theme . "melpa-stable")
                (cond-let . "melpa-stable")
                (dash . "melpa-stable")
                (dashboard . "melpa-stable")
                (diff-hl . "melpa-stable")
                (doom-modeline . "melpa-stable")
                (emmet-mode . "melpa")
                (evil . "melpa")
                (evil-collection . "melpa")
                (evil-surround . "melpa")
                (exec-path-from-shell . "melpa")
                (f . "melpa-stable")
                (goto-chg . "melpa")
                (hl-todo . "melpa-stable")
                (llama . "melpa-stable")
                (magit . "melpa-stable")
                (magit-section . "melpa-stable")
                (nerd-icons . "melpa-stable")
                (nerd-icons-completion . "melpa")
                (nerd-icons-dired . "melpa")
                (prettier-js . "melpa")
                (s . "melpa-stable")
                (shrink-path . "melpa-stable")
                (solaire-mode . "melpa-stable")
                (transient . "melpa-stable")
                (typescript-mode . "melpa")
                (with-editor . "melpa-stable")
                (web-mode . "melpa"))
              (bound-and-true-p package-pinned-packages)))

;;; post-early-init.el ends here
