;;; post-init.el --- Personal Emacs configuration -*- no-byte-compile: t; lexical-binding: t; -*-

;;; Code:

(add-to-list 'load-path
             (expand-file-name "lisp" minimal-emacs-user-directory))

(require 'init-core)
(require 'init-ui)
(require 'init-evil)
(require 'init-frontend)
(require 'init-completion)
(require 'init-tools)
(require 'init-keybindings)

;;; post-init.el ends here
