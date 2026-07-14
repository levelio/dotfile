# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Layout

Each top-level directory is a Stow package:

```text
nvim/.config/nvim/...
emacs/.config/emacs/...
neovide/.config/neovide/...
alacritty/.config/alacritty/...
zellij/.config/zellij/...
lazygit/Library/Application Support/lazygit/...
```

More packages can be added later, for example:

```text
zsh/.zshrc
git/.gitconfig
kitty/.config/kitty/kitty.conf
```

## Setup

Clone this repo to `~/dotfiles`, then use `stow` from the repo root:

```bash
brew install stow
cd ~/dotfiles
stow nvim neovide alacritty zellij lazygit
stow emacs
```

That will create:

```text
~/.config/nvim -> ~/dotfiles/nvim/.config/nvim
~/.config/emacs -> ~/dotfiles/emacs/.config/emacs
~/.config/neovide -> ~/dotfiles/neovide/.config/neovide
~/.config/alacritty -> ~/dotfiles/alacritty/.config/alacritty
~/.config/zellij -> ~/dotfiles/zellij/.config/zellij
~/Library/Application Support/lazygit/config.yml -> ~/dotfiles/lazygit/Library/Application Support/lazygit/config.yml
```

## Common Commands

Install a package:

```bash
stow alacritty
```

Restow after edits:

```bash
stow --restow alacritty
```

Remove symlinks for a package:

```bash
stow --delete alacritty
```

Install multiple packages:

```bash
stow nvim emacs neovide alacritty zellij lazygit
```

## Workflow

- Keep commits scoped to one tool or one purpose.
- Use package names that match the app or tool being configured.
- Put app configs under their native paths inside each package; most use `.config/...`, while some macOS tools use `Library/Application Support/...`.
- Keep machine-specific secrets or local-only files outside this repo.
