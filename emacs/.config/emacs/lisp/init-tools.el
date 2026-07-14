;;; init-tools.el --- Development tools -*- lexical-binding: t; -*-

;;; Code:

(unless noninteractive
  (use-package magit
    :commands (magit-blame-addition
               magit-diff
               magit-dispatch
               magit-log-current
               magit-status)))

(provide 'init-tools)

;;; init-tools.el ends here
