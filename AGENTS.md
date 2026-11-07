# Project instructions

## Purpose and layout

This repository maintains personal Fedora dotfiles and a symlink-based
installer. Read [README.md](README.md) for usage.

- `config/home/<user>/` mirrors files in the current user's home directory.
- `config/etc/` mirrors system configuration under `/etc`.
- `config/desktop/` contains manually restored desktop settings; it is not
  installed by the file-linking step.
- `install.sh` links configuration and backgrounds, backs up conflicting paths,
  and runs `scripts/setup-term.sh`.
- `docs/` contains reference material and project planning documents.

## Working boundaries

- Preserve unrelated staged, unstaged, and untracked changes.
- Do not inspect, expose, or commit credentials, private application data, or
  environment files. `.env` is ignored but existed in Git history, and
  historical `.backup/` files are tracked; neither is automatically safe to
  publish.
- The installer changes home and system files, invokes `sudo`, reloads udev,
  and runs terminal setup. Terminal setup can install packages, download
  external code, change the login shell, and modify `.zshrc`. Do not run these
  scripts on the real system merely to validate an unrelated change.
- Do not perform destructive actions, publish, or change system configuration
  without explicit authorization. Use isolated fixtures for behavioral tests
  and make skipped real-system checks clear.
- Follow existing patterns, surface errors, and document behavior changes.
  Keep hardware-specific and private data out of tracked configuration unless
  the owner explicitly approves its inclusion and publication.

## Validation

Choose checks appropriate to the changed files. For shell syntax, run:

```sh
bash -n install.sh scripts/setup-term.sh
```

Run `git diff --check` for tracked changes, and validate new untracked files
separately. Check relevant configuration formats and use isolated tests where
possible. There is no identified repository-wide test, lint, or build command;
do not treat syntax checks as proof that installation works. Report exact
checks, failures, and any unverified behavior.

## Project documents

- [SPEC](docs/SPEC.md): current requirements and verified baseline.
- [ROADMAP](docs/ROADMAP.md): separate outcomes, stages, and approvals.
- [TASKS](docs/TASKS.md): selected work, validation, and checkpoints.

Use the project workflow for feature lifecycle and approvals. Do not invent
features or mark tasks complete without evidence.
