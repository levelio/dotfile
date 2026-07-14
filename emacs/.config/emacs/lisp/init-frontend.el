;;; init-frontend.el --- Front-end development configuration -*- lexical-binding: t; -*-

;;; Code:

(defun zhq/frontend-mode-setup ()
  "Use front-end friendly indentation in the current buffer."
  (setq-local tab-width 2
              js-indent-level 2
              typescript-indent-level 2
              css-indent-offset 2
              web-mode-markup-indent-offset 2
              web-mode-css-indent-offset 2
              web-mode-code-indent-offset 2
              web-mode-script-padding 0
              web-mode-style-padding 0))

(defun zhq/frontend-server-executable ()
  "Return the preferred LSP server executable for the current buffer."
  (cond
   ((memq major-mode '(web-mode typescript-mode js-mode js-jsx-mode))
    "typescript-language-server")
   ((memq major-mode '(css-mode less-css-mode))
    "vscode-css-language-server")
   ((eq major-mode 'js-json-mode)
    "vscode-json-language-server")
   (t nil)))

(defun zhq/eglot-ensure-if-server ()
  "Start Eglot when a matching language server is available."
  (when (fboundp 'add-node-modules-path)
    (add-node-modules-path))
  (when-let ((server (zhq/frontend-server-executable)))
    (when (executable-find server)
      (eglot-ensure))))

(defun zhq/format-buffer ()
  "Format the current buffer using Prettier, Eglot, or indentation."
  (interactive)
  (cond
   ((and (memq major-mode '(web-mode typescript-mode js-mode js-json-mode
                                     css-mode less-css-mode))
         (fboundp 'prettier-js))
    (call-interactively #'prettier-js))
   ((and (bound-and-true-p eglot--managed-mode)
         (fboundp 'eglot-format-buffer))
    (eglot-format-buffer))
   (t
    (indent-region (point-min) (point-max)))))

(defun zhq/eslint-fix-file ()
  "Run eslint --fix for the current file."
  (interactive)
  (unless buffer-file-name
    (user-error "Current buffer is not visiting a file"))
  (when (buffer-modified-p)
    (save-buffer))
  (let ((eslint (or (executable-find "eslint_d")
                    (executable-find "eslint"))))
    (unless eslint
      (user-error "Neither eslint_d nor eslint was found in PATH"))
    (let ((buffer (get-buffer-create "*eslint fix*")))
      (with-current-buffer buffer
        (erase-buffer))
      (let ((exit-code (call-process eslint nil buffer t "--fix" buffer-file-name)))
        (if (zerop exit-code)
            (progn
              (revert-buffer :ignore-auto :noconfirm)
              (message "ESLint fixed %s" (file-name-nondirectory buffer-file-name)))
          (display-buffer buffer)
          (user-error "eslint --fix failed"))))))

(unless noninteractive
  ;; macOS GUI Emacs does not inherit the interactive shell PATH by default.
  (use-package exec-path-from-shell
    :if (memq window-system '(mac ns))
    :config
    (dolist (var '("PATH" "MANPATH" "NODE_PATH"))
      (add-to-list 'exec-path-from-shell-variables var))
    (exec-path-from-shell-initialize))

  (use-package web-mode
    :mode (("\\.tsx\\'" . web-mode)
           ("\\.jsx\\'" . web-mode)
           ("\\.html?\\'" . web-mode)
           ("\\.vue\\'" . web-mode)
           ("\\.astro\\'" . web-mode))
    :hook (web-mode . zhq/frontend-mode-setup)
    :custom
    (web-mode-enable-auto-quoting nil)
    (web-mode-enable-current-element-highlight t)
    (web-mode-enable-current-column-highlight nil))

  (use-package typescript-mode
    :mode (("\\.ts\\'" . typescript-mode)
           ("\\.mts\\'" . typescript-mode)
           ("\\.cts\\'" . typescript-mode))
    :hook (typescript-mode . zhq/frontend-mode-setup))

  (use-package js
    :ensure nil
    :mode (("\\.js\\'" . js-mode)
           ("\\.mjs\\'" . js-mode)
           ("\\.cjs\\'" . js-mode)
           ("\\.json\\'" . js-json-mode)
           ("\\.jsonc\\'" . js-json-mode))
    :hook ((js-mode . zhq/frontend-mode-setup)
           (js-json-mode . zhq/frontend-mode-setup)))

  (use-package css-mode
    :ensure nil
    :mode (("\\.css\\'" . css-mode)
           ("\\.scss\\'" . css-mode))
    :hook (css-mode . zhq/frontend-mode-setup))

  (use-package less-css-mode
    :ensure nil
    :mode ("\\.less\\'" . less-css-mode)
    :hook (less-css-mode . zhq/frontend-mode-setup))

  (use-package add-node-modules-path
    :hook ((web-mode . add-node-modules-path)
           (typescript-mode . add-node-modules-path)
           (js-mode . add-node-modules-path)
           (js-json-mode . add-node-modules-path)
           (css-mode . add-node-modules-path)
           (less-css-mode . add-node-modules-path)))

  (use-package eglot
    :ensure nil
    :commands (eglot
               eglot-ensure
               eglot-code-actions
               eglot-find-declaration
               eglot-find-implementation
               eglot-format-buffer
               eglot-reconnect
               eglot-rename)
    :hook ((web-mode . zhq/eglot-ensure-if-server)
           (typescript-mode . zhq/eglot-ensure-if-server)
           (js-mode . zhq/eglot-ensure-if-server)
           (js-json-mode . zhq/eglot-ensure-if-server)
           (css-mode . zhq/eglot-ensure-if-server)
           (less-css-mode . zhq/eglot-ensure-if-server))
    :custom
    (eglot-autoshutdown t)
    (eglot-confirm-server-edits nil)
    :config
    (add-to-list
     'eglot-server-programs
     '(((web-mode :language-id "typescriptreact"))
       . ("typescript-language-server" "--stdio")))
    (add-to-list
     'eglot-server-programs
     '(((css-mode :language-id "css")
        (less-css-mode :language-id "less"))
       . ("vscode-css-language-server" "--stdio"))))

  (use-package prettier-js
    :commands (prettier-js prettier-js-mode)
    :hook ((web-mode . prettier-js-mode)
           (typescript-mode . prettier-js-mode)
           (js-mode . prettier-js-mode)
           (js-json-mode . prettier-js-mode)
           (css-mode . prettier-js-mode)
           (less-css-mode . prettier-js-mode))
    :custom
    (prettier-js-show-errors 'echo))

  (use-package emmet-mode
    :hook ((web-mode . emmet-mode)
           (css-mode . emmet-mode)
           (less-css-mode . emmet-mode))))

(provide 'init-frontend)

;;; init-frontend.el ends here
