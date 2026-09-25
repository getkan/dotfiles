-- ========================================================================== --
-- ==                           EDITOR SETTINGS                            == --
-- ========================================================================== --

-- Learn more about Neovim lua api
-- https://neovim.io/doc/user/lua-guide.html
-- https://vonheikemen.github.io/devlog/tools/build-your-first-lua-config-for-neovim/

vim.o.number = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = false
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.showmode = false
vim.o.termguicolors = true
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.signcolumn = 'yes'
vim.o.winborder = 'rounded'
vim.o.linebreak = true
vim.opt.spell = true
vim.opt.spelllang = 'en_us'

-- Space as leader key
vim.g.mapleader = vim.keycode('<Space>')

-- Basic clipboard interaction
vim.keymap.set({'n', 'x'}, 'gy', '"+y', {desc = 'Copy to clipboard'})
vim.keymap.set({'n', 'x'}, 'gp', '"+p', {desc = 'Paste clipboard content'})

-- ========================================================================== --
-- ==                               PLUGINS                                == --
-- ========================================================================== --

-- NOTE: To install a plugin you just need to add the URL to the repository.
-- But as soon as you need to add more information, like the git branch or 
-- commit, use the "plugin spec" form. See :help vim.pack

vim.pack.add({
  'https://github.com/folke/tokyonight.nvim',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/neovim/nvim-lspconfig',
  {src = 'https://github.com/nvim-mini/mini.nvim', version = 'main'},
  {src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main'},
  'https://github.com/MeanderingProgrammer/render-markdown.nvim',
  'https://github.com/hedyhli/outline.nvim',
})

-- ========================================================================== --
-- ==                         PLUGIN CONFIGURATION                         == --
-- ========================================================================== --

vim.cmd.colorscheme('tokyonight')

-- See :help MiniIcons.config
-- Change style to 'glyph' if you have a font with fancy icons
require('mini.icons').setup({style = 'ascii'})

-- See :help MiniSurround.config
require('mini.surround').setup({})

-- See :help MiniNotify.config
require('mini.notify').setup({
  lsp_progress = {enable = false},
})

-- See :help MiniBufremove.config
require('mini.bufremove').setup({})

-- Close buffer and preserve window layout
vim.keymap.set('n', '<leader>bc', '<cmd>lua pcall(MiniBufremove.delete)<cr>', {desc = 'Close buffer'})

-- See :help MiniFiles.config
local mini_files = require('mini.files')
mini_files.setup({})

-- Toggle file explorer
-- See :help MiniFiles-navigation
vim.keymap.set('n', '<leader>f', function()
  if mini_files.close() then
    return
  end

  mini_files.open()
end, {desc = 'File explorer'})

-- See :help MiniPick.config
require('mini.pick').setup({})

-- See available pickers
-- :help MiniPick.builtin
-- :help MiniExtra.pickers
vim.keymap.set('n', '<leader>?', '<cmd>Pick oldfiles<cr>', {desc = 'Search file history'})
vim.keymap.set('n', '<leader>b', '<cmd>Pick buffers<cr>', {desc = 'Search open files'})
vim.keymap.set('n', '<leader>ff', '<cmd>Pick files<cr>', {desc = 'Search all files'})
vim.keymap.set('n', '<leader>fg', '<cmd>Pick grep_live<cr>', {desc = 'Search in project'})
vim.keymap.set('n', '<leader>fd', '<cmd>Pick diagnostic<cr>', {desc = 'Search diagnostics'})
vim.keymap.set('n', '<leader>fs', '<cmd>Pick buf_lines<cr>', {desc = 'Buffer local search'})

-- See :help MiniStatusline.config
require('mini.statusline').setup({})

-- See :help MiniExtra
require('mini.extra').setup({})

-- See :help MiniSnippets.config
require('mini.snippets').setup({})

-- See :help MiniCompletion.config
require('mini.completion').setup({
  lsp_completion = {
    source_func = 'omnifunc',
    auto_setup = false,
  },
})

-- See :help which-key.nvim-which-key-setup
require('which-key').setup({
  preset = 'helix',
  icons = {
    mappings = false,
    keys = {
      Space = 'Space',
      Esc = 'Esc',
      BS = 'Backspace',
      C = 'Ctrl-',
    },
  },
})

require('which-key').add({
  {'<leader>f', group = 'Fuzzy Find'},
  {'<leader>b', group = 'Buffer'},
  {'<leader>o', desc = 'Outline'},
})

require('outline').setup({})
vim.keymap.set('n', '<leader>o', '<cmd>Outline<cr>', {desc = 'Outline'})

-- See :help render-markdown.nvim-configuration
-- Start disabled; <leader>v / <leader>mv toggle the rendered view.
require('render-markdown').setup({enabled = false})

-- Toggle rendered markdown view/editor for the current buffer
local render_markdown_enabled = {}
local function toggle_markdown_view()
  local buf = vim.api.nvim_get_current_buf()
  local enable = not render_markdown_enabled[buf]
  render_markdown_enabled[buf] = enable

  local render = require('render-markdown')
  if enable then
    render.buf_enable()
  else
    render.buf_disable()
  end

  vim.notify('render-markdown: ' .. (enable and 'viewer' or 'editor'), vim.log.levels.INFO)
end

vim.keymap.set('n', '<leader>v', toggle_markdown_view, {desc = 'Toggle markdown viewer/editor'})
vim.keymap.set('n', '<leader>mv', toggle_markdown_view, {desc = 'Toggle markdown viewer/editor'})

-- Treesitter setup
-- Try to update all parsers after a plugin update
vim.api.nvim_create_autocmd('PackChanged', {
  pattern = 'nvim-treesitter',
  desc = 'Update treesitter parsers',
  command = 'TSUpdate'
})

-- Autosave on type
vim.api.nvim_create_autocmd({'TextChanged', 'TextChangedI', 'InsertLeave'}, {
  desc = 'Autosave on type',
  callback = function(event)
    if vim.bo[event.buf].buftype == '' and vim.api.nvim_buf_get_name(event.buf) ~= '' then
      vim.cmd('silent! update')
    end
  end,
})

-- NOTE: treesitter features **must** be enabled manually
-- https://github.com/nvim-treesitter/nvim-treesitter#supported-features
vim.api.nvim_create_autocmd('FileType', {
  pattern = {'lua', 'vim', 'help', 'markdown'},
  callback = function()
    -- Enable treesitter based syntax highlight
    pcall(vim.treesitter.start)
  end
})

-- LSP setup
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local opts = {buffer = event.buf}
    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
    vim.keymap.set('n', 'grd', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
    vim.keymap.set({'n', 'x'}, 'gq', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)

    local id = vim.tbl_get(event, 'data', 'client_id')
    local client = id and vim.lsp.get_client_by_id(id)

    if client and client:supports_method('textDocument/completion') then
      vim.bo[event.buf].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'
    end
  end,
})

require('reformat').setup()

