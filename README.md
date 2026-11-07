# dotfiles

Personal Fedora config files, installed via symlinks so the repo stays the
single source of truth.

## Layout

`config/` mirrors the Fedora filesystem it gets installed onto. Home files are
stored below the account they belong to:

- `config/home/<user>/...` -> `/home/<user>/...` (e.g. `config/home/<user>/.bashrc` -> `/home/<user>/.bashrc`)
- `config/home/<user>/.config/nvim/` -> `/home/<user>/.config/nvim/` ([nvim-light](https://github.com/VonHeikemen/nvim-light) config, leader key is `Ctrl+Alt+A`)
- `config/home/<user>/.config/tmux/` -> `/home/<user>/.config/tmux/` (Tokyo Night Moon theme and Vim-style navigation)
- `config/etc/...` -> `/etc/...` (requires sudo, e.g. `config/etc/udev/rules.d/10-wakeup.rules` -> `/etc/udev/rules.d/10-wakeup.rules`)
- `img/backgrounds/*` -> `~/.local/share/backgrounds/`

`install.sh` installs `config/home/<user>/` into the current account's home
directory. Set `DOTFILES_USER` in `.env` to the username returned by `id -un`;
the installer rejects missing, malformed, or mismatched values. Add a new file
under `config/home/<user>/` to have it symlinked into the matching location.

`install.sh` also runs `scripts/setup-term.sh`, which installs and configures
the terminal environment (zsh, Oh My Zsh, zsh-autosuggestions, Starship,
tmux, Ghostty).

The managed user preferences include Code and Cursor settings, LunarVim, QMK,
Ulauncher, Terminator, Clipse appearance, terminal selection, MIME
associations, and XDG user-directory settings. Browser data, editor state,
caches, history, the monitor layout, and credentials remain outside the
repository.

For the current Fedora desktop inventory and safe reinstall/home-sharing plan,
see [Fedora configuration inventory](docs/fedora_configuration_inventory.md) and
[Safely Reinstalling Fedora](docs/fedora_safe_reinstall.md). These are not a
substitute for a verified encrypted backup. `.env` and historical `.backup/`
files need special care: `.env` is ignored for future commits but may remain in
older Git history, and historical `.backup/` files are still tracked. Review
them and the history before publishing; do not commit secrets. The installer
accepts only the two documented settings in `.env`, not arbitrary secret entries.

## Usage

Create the local environment file and set the username for the system where
the configuration will be installed:

```sh
cp .env.example .env
# Edit .env, set DOTFILES_USER to the output of: id -un
# Set AGENT_COMMAND to either codex or opencode
```

Then run:

```sh
./install.sh
```

The script is idempotent and backs up any pre-existing files it would
otherwise overwrite into `.backup/<timestamp>/`.

## GNOME background

Set the background color shown around a centered wallpaper:

```sh
gsettings set org.gnome.desktop.background primary-color '#202020'
```

## tmux

See [TMUX.md](TMUX.md) for installation verification, keybindings, session
management, and a proposed tmux, Neovim, and OpenCode development workflow.

## Neovim

`config/home/<user>/.config/nvim/` is the `stable.lua` config from
[nvim-light](https://github.com/VonHeikemen/nvim-light) (targets NVIM v0.12+),
paired with its `.luarc.json`.

### Requirements

- Neovim v0.12 or greater.
- `git`.
- The [tree-sitter CLI](https://github.com/tree-sitter/tree-sitter).
- A `C` compiler.
- A language server, to enable IDE-like features.
- (optional) [ripgrep](https://github.com/BurntSushi/ripgrep), for faster project-wide search.
- (optional) [fd](https://github.com/sharkdp/fd), for faster file search.

### Plugin list

| Plugin | Purpose |
| --- | --- |
| tokyonight.nvim | Collection of colorschemes for Neovim. |
| which-key.nvim | Provides clues for keymaps. |
| mini.nvim | Collection of independent lua modules that enhance Neovim's features. |
| nvim-treesitter | Manages treesitter parsers and provides query files for supported languages. |
| nvim-lspconfig | Quickstart configs for Neovim's LSP client. |
| render-markdown.nvim | Renders Markdown syntax as formatted text in the editor. |
| outline.nvim | Displays a symbol outline for the current buffer. |

### Plugin commands

| Plugin | Command | Description |
| --- | --- | --- |
| tokyonight.nvim | `:colorscheme tokyonight` | Apply the configured colorscheme. |
| which-key.nvim | `:WhichKey` | Show available keymaps for the current prefix. |
| mini.nvim | `:Pick` | Open MiniPick; use a picker such as `:Pick files`, `:Pick buffers`, `:Pick oldfiles`, `:Pick grep_live`, `:Pick diagnostic`, or `:Pick buf_lines`. |
| netrw (built-in) | `:Lexplore` | Open the file explorer in a left-side split. |
| nvim-treesitter | `:TSInstall <language>` | Install a parser. |
| nvim-treesitter | `:TSUpdate` | Update installed parsers. |
| nvim-treesitter | `:TSUninstall <language>` | Remove a parser. |
| nvim-treesitter | `:TSInstallFromGrammar <language> <path>` | Install a parser from a local grammar repository. |
| nvim-treesitter | `:TSLog` | Open the Treesitter log. |
| render-markdown.nvim | `:RenderMarkdown toggle` | Toggle Markdown rendering for the current buffer. |
| outline.nvim | `:Outline` | Toggle the symbol outline. |

`mini.icons`, `mini.surround`, `mini.notify`, `mini.bufremove`, `mini.files`,
`mini.statusline`, `mini.extra`, `mini.snippets`, and `mini.completion` are
configured Lua modules; they do not add a dedicated Ex command in this config.
`nvim-lspconfig` is configured through Neovim's built-in LSP API and likewise
does not add a dedicated Ex command.

### Keybindings

Leader key: `Ctrl+Alt+A`.

| Mode | Keybinding | Description |
| --- | --- | --- |
| Normal | `gy` | Copy text to clipboard. |
| Normal | `gp` | Paste text from clipboard. |
| Normal | `K` | Displays hover information about the symbol under the cursor. |
| Normal | `gd` | Jump to the definition. |
| Normal | `gq` | Format code in current buffer. |
| Normal | `grd` | Jump to declaration. |
| Normal | `gcc` | Toggle comment in current line. |
| Operator | `gc` | Toggle comment in text. |
| Normal | `<leader>f` | Toggle file explorer. |
| Normal | `<leader>bc` | Close current buffer and preserve window layout. |
| Normal | `<leader>?` | Search oldfiles history. |
| Normal | `<leader>b` | Search open buffers. |
| Normal | `<leader>ff` | Find file in current working directory. |
| Normal | `<leader>fg` | Search pattern in current working directory (live grep). |
| Normal | `<leader>fd` | Search diagnostics in current file. |
| Normal | `<leader>fs` | Search pattern in current file. |
| Normal | `<leader>o` | Toggle the symbol outline. |
| Normal | `<leader>v` | Toggle rendered Markdown for the current buffer. |
| Normal | `<leader>mv` | Toggle rendered Markdown for the current buffer. |
| Visual | `<leader>r` | Reformat the selected text as Markdown. |

### Reformatting text

`:Reformat` (accepts a range, e.g. `:'<,'>Reformat` on a visual selection)
sends the selected text to the `getkan-ai` agent's `reformat` skill, which
normalizes whitespace, line breaks, tabs, and bullet points into Markdown
without changing any words. Requires the selected `codex` or `opencode` CLI
to be installed and configured; see `lua/reformat.lua`. In Visual mode, press
`<leader>r` to run the command on the current selection. The backend is selected by
`AGENT_COMMAND=codex` or `AGENT_COMMAND=opencode` in `.env`; rerun
`./install.sh` after creating the file so GUI-launched Neovim can read it.

#### Autocomplete keybindings

| Mode | Keybinding | Description |
| --- | --- | --- |
| Insert | `<Up>` | Move to previous item. |
| Insert | `<Down>` | Move to next item. |
| Insert | `<Ctrl-p>` | Move to previous item and insert content. |
| Insert | `<Ctrl-n>` | Move to next item and insert content. |
| Insert | `<Ctrl-y>` | Confirm completion. |
| Insert | `<Enter>` | Confirm completion if item was selected with Up or Down arrows. |
| Insert | `<Ctrl-e>` | Cancel completion. |

The first time `nvim` is launched, plugins are downloaded automatically via
`vim.pack`. Install treesitter parsers with `:TSInstall <language>` and enable
a language server with `vim.lsp.enable('<name>')`.
