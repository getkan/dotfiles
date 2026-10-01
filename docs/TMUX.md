# tmux quickstart

The managed tmux configuration uses `Ctrl+a` as its prefix, one-based window
and pane indexes, Vim-style pane navigation, mouse support, system clipboard
integration, and the Tokyo Night Moon palette shared by Ghostty and Neovim.

The status line uses Nerd Font glyphs. Select a Nerd Font in Ghostty if those
icons appear as empty boxes.

## Install

Run the dotfiles installer from the repository root:

```sh
./install.sh
```

The installer installs tmux when needed and links the configuration to
`~/.config/tmux/tmux.conf`. Verify the result with:

```sh
tmux -V
readlink -f ~/.config/tmux/tmux.conf
```

Start tmux in the current directory:

```sh
tmux
```

Commands described as `prefix` below begin with `Ctrl+a`. Press and release
`Ctrl+a`, then press the following key.

## Sessions

```sh
# Start or attach to a named project session.
tmux new-session -A -s project

# List sessions.
tmux list-sessions

# Attach to an existing session.
tmux attach-session -t project

# End a session.
tmux kill-session -t project
```

Detach from the current session with `prefix d`. The programs in its windows
continue running in the background. Use `prefix s` to choose another session
and `prefix $` to rename the current session.

## Windows and panes

| Action | Keybinding |
| --- | --- |
| Create window | `prefix c` |
| Rename window | `prefix ,` |
| Next / previous window | `Shift+Right` / `Shift+Left` |
| Select window 1-9 | `Alt+1` through `Alt+9` |
| Split horizontally | `prefix \|` |
| Split vertically | `prefix -` |
| Move between panes | `Alt+h/j/k/l` |
| Move between panes after prefix | `prefix h/j/k/l` |
| Close a pane or window | Exit its shell with `exit` or `Ctrl+d` |
| Reload configuration | `prefix r` |
| Show tmux commands | `prefix ?` |

New panes inherit the current pane's working directory. Mouse support also
allows selecting panes, resizing pane borders, changing windows, and scrolling.

## Copy mode

1. Enter copy mode with `prefix [`.
2. Move with Vim keys or the arrow keys.
3. Press `v` to begin a selection, or `Ctrl+v` for a rectangular selection.
4. Press `y` to copy and leave copy mode.

Press `q` to leave copy mode without copying. Clipboard forwarding depends on
terminal and desktop clipboard support; tmux's `set-clipboard` option is enabled.

## Proposed development workflow

Keep one named tmux session per repository so the entire development context
survives terminal restarts:

```sh
cd ~/Projects/example
tmux new-session -A -s example
```

1. Use window 1 for Neovim: run `nvim .` and keep editing, navigation, and LSP
   work together there.
2. Create window 2 with `prefix c`, rename it `ai` with `prefix ,`, and run
   `opencode` from the repository root. Review its proposed changes in Neovim.
3. Create window 3 named `run` for tests, builds, logs, or a development server.
   Split it with `prefix -` when a second shell or log stream is useful.
4. Jump directly between the three roles with `Alt+1`, `Alt+2`, and `Alt+3`.
   Within a split window, use `Alt+h/j/k/l` without entering prefix mode.
5. Detach with `prefix d` when stopping work. Resume the same layout later with
   `tmux new-session -A -s example`.

This keeps editing, AI assistance, and runtime feedback separated while sharing
one persistent project environment and working directory.