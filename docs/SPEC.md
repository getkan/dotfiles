# Dotfiles project specification

## Purpose

Maintain personal Fedora configuration in a repository and restore selected
settings using symlinks. The intended user controls a Linux workstation and
needs to inspect changes before applying system-wide configuration.

## Verified baseline

- [README.md](../README.md) describes the configuration layout and usage.
- [install.sh](../install.sh) reads a local `.env`, links home and `/etc`
  configuration and backgrounds, backs up conflicting destinations, and calls
  the terminal setup script. It warns rather than exits on a non-Fedora system.
- [scripts/setup-term.sh](../scripts/setup-term.sh) supports package-manager
  detection for DNF, apt, and pacman; it can install tools, run downloaded
  scripts, change the default shell, and edit `.zshrc`. Detection is not proof
  of full support on every distribution.
- [Fedora reinstall guide](fedora_safe_reinstall.md) and
  [configuration inventory](fedora_configuration_inventory.md) are reference
  documentation, not a complete backup.
- Bash is the installer language. No repository-wide automated test, lint, or
  build command has been identified. Full distribution and version support,
  automated behavioral coverage, and any deployment environment are not
  established.

## Existing behavior and constraints

1. Home and system configuration are maintained under `config/home/<user>/`
   and `config/etc/` respectively. The installer uses the current home
   directory and `sudo` for system links.
2. The installer requires a matching `DOTFILES_USER` and an `AGENT_COMMAND` of
   `codex` or `opencode` in `.env`; `.env.example` documents the format.
3. Existing destination files are backed up before replacement; already-correct
   links are left in place. The installer also performs terminal setup, so
   running it is not a read-only operation.
4. Credentials and private data are not suitable for publication in the
   repository. A separate verified encrypted backup is needed for system and
   personal data; the dotfiles repository does not replace one.

These are observations of the current implementation, not approval of further
requirements or a guarantee of recovery. Any new feature should specify its
own measurable acceptance criteria and compatibility decisions.

## Acceptance evidence

- Review changed configurations for private information before committing.
- Validate shell syntax and changed file formats; test installer behavior in an
  isolated environment when modifying it.
- Record exact results and explicitly identify checks that were not performed.

## Approved changes and open decisions

Project documentation setup is tracked as `project-setup` in
[ROADMAP.md](ROADMAP.md) and [TASKS.md](TASKS.md). No future feature scope,
platform expansion, or automated test policy has been approved.
