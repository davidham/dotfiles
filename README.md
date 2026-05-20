# dotfiles

Personal dotfiles managed by [Dotbot](https://github.com/anishathalye/dotbot).
zsh-first; macOS-only assumptions; XDG conventions where supported.

## Layout

```
home/   files symlinked into $HOME (.zshrc, .zprofile, .editorconfig, .yarnrc.yml)
xdg/    files symlinked under ~/.config/ (git, npm, ghostty, zellij, nvim, direnv)
shell/  zsh modules sourced by home/zshrc.zsh (env, aliases, functions, prompt, fzf, local example)
scripts/  helper scripts (lint)
```

The directory name documents the symlink target. `home/X` -> `~/.X`.
`xdg/<tool>/file` -> `~/.config/<tool>/file`. `shell/*.zsh` is sourced,
not symlinked.

## Bootstrap on a fresh machine

```bash
git clone git@github.com:davidham/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install                 # creates symlinks; pulls dotbot submodule
pre-commit install        # enables the git hook for secret scanning
```

Required tools (install with Homebrew):

```bash
brew install gitleaks shellcheck shfmt pre-commit fzf
```

Optional tools the shell adapts to (no errors if absent):

- `fd` or `ripgrep` -- nicer file source for fzf's Ctrl-T. `brew install fd ripgrep`
- `tree` -- used by the `tre` shell function. `brew install tree`
- `jq` -- used by the `download_secret` / `upload_secret` AWS helpers. `brew install jq`
- `awscli`, `aws-vault`, `kubectl`, `terraform`, `docker`, `bazel` -- aliases reference these but only when invoked.
- `direnv` -- if installed, hooked at shell startup. If absent, no error.
- `apollo-cli` -- Grafana-internal; if installed, completions load.
- Google Cloud SDK at `~/google-cloud-sdk` -- if installed, paths and completions load.

asdf, gcloud, Docker, etc. are managed outside this repo.

## Adding a shell module

Drop a file in `shell/` ending in `.zsh`. Source it from `home/zshrc.zsh`
in the `for module in env aliases ... ; do` loop -- order matters
(env first).

## Per-machine overrides

Anything machine-local (e.g., a work-specific export, SSH key auto-load
with a non-default path) goes in
`${XDG_CONFIG_HOME:-$HOME/.config}/shell-local.zsh`. This file is
gitignored. `shell/local.zsh.example` is the template; copy it once and
edit in place.

## Linting

```bash
./scripts/lint            # runs pre-commit on every file
```

CI mirrors this. See `.github/workflows/ci.yml`.

## Secrets

Never commit secrets. Patterns:

- Files containing real secrets are gitignored and live outside the repo.
- Template files end in `.example` or `.tmpl` and contain placeholders.
- gitleaks runs at commit time and in CI; it blocks accidental secret
  pushes. The repo allowlists `*.example` and `*.tmpl` paths.
- GitHub push protection is enabled as a final backstop.

If you discover a leaked credential in history: rotate the credential
first, decide whether to rewrite history second. Rotation is fast;
rewriting public history is loud and breaks forks.
