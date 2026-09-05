# dotfiles

Personal Fedora config files, installed via symlinks so the repo stays the
single source of truth.

## Layout

`config/` mirrors the Fedora filesystem it gets installed onto:

- `config/home/...` -> `~/...` (e.g. `config/home/.bashrc` -> `~/.bashrc`)
- `config/home/.config/nvim/` -> `~/.config/nvim/` ([nvim-light](https://github.com/VonHeikemen/nvim-light) config, leader key is `<Space>`)
- `config/etc/...` -> `/etc/...` (requires sudo, e.g. `config/etc/udev/rules.d/10-wakeup.rules` -> `/etc/udev/rules.d/10-wakeup.rules`)
- `img/backgrounds/*` -> `~/.local/share/backgrounds/`

Every file under `config/` is symlinked into place automatically; add a new
file at the matching mirrored path to have `install.sh` pick it up.

`install.sh` also runs `scripts/setup-term.sh`, which installs and configures
the terminal environment (zsh, Oh My Zsh, zsh-autosuggestions, Starship,
Ghostty).

## Usage

```sh
./install.sh
```

The script is idempotent and backs up any pre-existing files it would
otherwise overwrite into `.backup/<timestamp>/`.

## Neovim

`config/home/.config/nvim/` is the `stable.lua` config from
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

### Keybindings

Leader key: `Space`.

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
| Normal | `<leader><space>` | Search open buffers. |
| Normal | `<leader>ff` | Find file in current working directory. |
| Normal | `<leader>fg` | Search pattern in current working directory (live grep). |
| Normal | `<leader>fd` | Search diagnostics in current file. |
| Normal | `<leader>fs` | Search pattern in current file. |

### Reformatting text

`:Reformat` (accepts a range, e.g. `:'<,'>Reformat` on a visual selection)
sends the selected text to the `getkan-ai` agent's `reformat` skill, which
normalizes whitespace, line breaks, tabs, and bullet points into Markdown
without changing any words. Requires the `codex` CLI to be installed and
configured; see `lua/reformat.lua`.

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
