;;; init-evil.el --- Vim editing configuration -*- lexical-binding: t; -*-

;;; Code:

(defvar-local zhq/evil-escape-last-j nil
  "Timestamp of the last j pressed in Evil insert state.")

(defconst zhq/evil-escape-delay 0.22
  "Maximum delay between j and j/k for leaving insert state.")

(defun zhq/evil-insert-j ()
  "Insert j, or leave insert state when pressed after j."
  (interactive)
  (let ((now (float-time)))
    (if (and zhq/evil-escape-last-j
             (< (- now zhq/evil-escape-last-j) zhq/evil-escape-delay))
        (progn
          (setq zhq/evil-escape-last-j nil)
          (delete-backward-char 1)
          (evil-normal-state))
      (setq zhq/evil-escape-last-j now)
      (self-insert-command 1))))

(defun zhq/evil-insert-k ()
  "Insert k, or leave insert state when pressed after j."
  (interactive)
  (let ((now (float-time)))
    (if (and zhq/evil-escape-last-j
             (< (- now zhq/evil-escape-last-j) zhq/evil-escape-delay))
        (progn
          (setq zhq/evil-escape-last-j nil)
          (delete-backward-char 1)
          (evil-normal-state))
      (setq zhq/evil-escape-last-j nil)
      (self-insert-command 1))))

(unless noninteractive
  (use-package evil
    :init
    (setq evil-want-integration t
          evil-want-keybinding nil)
    :custom
    (evil-ex-visual-char-range t)
    (evil-ex-search-vim-style-regexp t)
    (evil-split-window-below t)
    (evil-vsplit-window-right t)
    (evil-echo-state nil)
    (evil-move-cursor-back nil)
    (evil-v$-excludes-newline t)
    (evil-want-C-h-delete t)
    (evil-want-C-u-delete t)
    (evil-want-fine-undo t)
    (evil-search-wrap nil)
    (evil-undo-system 'undo-redo)
    (evil-want-Y-yank-to-eol t)
    :config
    (evil-mode 1))

  (use-package evil-collection
    :after evil
    :init
    (setq evil-collection-setup-minibuffer t)
    :config
    (evil-collection-init))

  (use-package evil-surround
    :after evil
    :config
    (global-evil-surround-mode 1))

  (use-package goto-chg
    :commands (goto-last-change goto-last-change-reverse)))

(provide 'init-evil)

;;; init-evil.el ends here
