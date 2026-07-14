# Emacs

This package is based on
[jamescherti/minimal-emacs.d](https://github.com/jamescherti/minimal-emacs.d)
at commit `dba8434`.

`init.el` and `early-init.el` are upstream minimal-emacs.d files. Local
configuration lives in:

- `pre-early-init.el`: machine-local startup paths and UI defaults.
- `post-early-init.el`: settings that need to run after minimal early init.
- `post-init.el`: loads the personal modules in dependency order.
- `lisp/init-core.el`: built-in defaults and project commands.
- `lisp/init-ui.el`: theme, fonts, modeline, dashboard, and visual helpers.
- `lisp/init-evil.el`: Evil packages and insert-state escape behavior.
- `lisp/init-frontend.el`: React, TypeScript, CSS, Eglot, Prettier, and ESLint.
- `lisp/init-completion.el`: Vertico, Consult, Corfu, and completion helpers.
- `lisp/init-tools.el`: development tools such as Magit.
- `lisp/init-keybindings.el`: Evil motions and the `SPC` leader hierarchy.

Runtime state, packages, native compilation cache, history, and customizations
are redirected to `~/.local/state/emacs/` so the stowed config stays clean.

## Visual Stack

The UI keeps the minimal-emacs base but adds a polished dark coding setup:

- Theme: `catppuccin-theme` using the Mocha flavor
- Modeline: `doom-modeline` with Nerd Font icons
- Startup screen: `dashboard`
- Icons: `nerd-icons`, `nerd-icons-completion`, and `nerd-icons-dired`
- Git gutter: `diff-hl`
- TODO/FIXME highlighting: `hl-todo`
- Subtle inactive-buffer dimming: `solaire-mode`

On macOS GUI frames, the config prefers `Maple Mono NF CN`, then JetBrains
Nerd Font variants, so English, Chinese, and icons render consistently.

## Front-end Stack

The local configuration is tuned for React and TypeScript projects:

- TSX/JSX/HTML/Vue/Astro: `web-mode`
- TypeScript: `typescript-mode`
- JavaScript/JSON: built-in `js-mode` and `js-json-mode`
- CSS/Less/SCSS: built-in CSS modes
- LSP: `eglot` with `typescript-language-server`,
  `vscode-css-language-server`, and `vscode-json-language-server`
- Formatting: `prettier-js`
- HTML/CSS expansion: `emmet-mode`

The macOS GUI app imports shell `PATH` through `exec-path-from-shell`, and
project-local `node_modules/.bin` is prepended through `add-node-modules-path`.

## Keybindings

The Evil leader is inspired by AstroNvim:

- `SPC f f`: find file in project
- `SPC f m`: jump to mark
- `SPC f w`: search project text
- `SPC b b`: switch buffer
- `SPC g g`: Magit status
- `SPC l a`: code action
- `SPC l f`: format buffer
- `SPC l r`: rename symbol
- `SPC l d`: buffer diagnostics
- `SPC t n`: run a package.json script
- `SPC t d`: run `dev`
- `SPC t T`: run `test`
- `SPC w h/j/k/l`: move between windows
- `jk` or `jj`: leave insert state
- `[d` / `]d`: previous/next diagnostic

## Commands

```bash
stow emacs
emacs --debug-init
```

To test without changing symlinks:

```bash
emacs --init-directory ~/dotfiles/emacs/.config/emacs --debug-init
```
