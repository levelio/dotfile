;;; init-completion.el --- Completion and search configuration -*- lexical-binding: t; -*-

;;; Code:

(unless noninteractive
  (use-package vertico
    :init
    (vertico-mode 1))

  (use-package orderless
    :custom
    (completion-styles '(orderless basic))
    (completion-category-overrides '((file (styles partial-completion))))
    (completion-pcm-leading-wildcard t))

  (use-package marginalia
    :init
    (marginalia-mode 1))

  (use-package consult
    :commands (consult-buffer
               consult-git-grep
               consult-imenu
               consult-line
               consult-mark
               consult-recent-file
               consult-ripgrep)
    :bind (("C-x b" . consult-buffer)
           ("M-s l" . consult-line)
           ("M-s r" . consult-ripgrep)
           ("M-y" . consult-yank-pop))
    :init
    (setq xref-show-xrefs-function #'consult-xref
          xref-show-definitions-function #'consult-xref))

  (use-package corfu
    :custom
    (corfu-auto t)
    (corfu-cycle t)
    (corfu-count 12)
    (corfu-preview-current nil)
    :config
    (global-corfu-mode 1))

  (use-package cape
    :commands (cape-dabbrev cape-file cape-elisp-block)
    :init
    (add-hook 'completion-at-point-functions #'cape-dabbrev)
    (add-hook 'completion-at-point-functions #'cape-file)
    (add-hook 'completion-at-point-functions #'cape-elisp-block)))

(provide 'init-completion)

;;; init-completion.el ends here
