vim.g.loaded_netrw = true
vim.g.loaded_netrwPlugin = true 
vim.g.mapleader = ' '

local opt       = vim.opt

opt.syntax      = 'enable'
opt.mouse       = 'a'
opt.number      = true
opt.smarttab    = true
opt.expandtab   = true
opt.smartcase   = true
opt.tabstop     = 4
opt.shiftwidth  = 4
opt.splitbelow  = true
opt.splitright  = true

--------------------------------------------------
-- Plugins
--------------------------------------------------

local lazypath  = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end

opt.rtp:prepend(lazypath)

local plugins = {
  { 'nvim-treesitter/nvim-treesitter',  build = ':TSUpdate', event = { 'BufReadPre', 'BufNewFile' } },
  { 'neovim/nvim-lspconfig' },
  { 'williamboman/mason.nvim' },
  { 'williamboman/mason-lspconfig.nvim' },
  { 'sainnhe/gruvbox-material' },
  { 'hrsh7th/nvim-cmp',                 event = { 'InsertEnter', 'CmdlineEnter' } }, -- autocompletion
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'windwp/nvim-autopairs' },
  { 'nvim-tree/nvim-tree.lua' },
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },
}

require('lazy').setup(plugins)

require('telescope').setup {
  defaults = {
    file_ignore_patterns = { 'node_modules', '.git' },
  },
}

require('nvim-treesitter.configs').setup {
  ensure_installed = { 'odin', 'lua', 'javascript', 'c', 'cpp', 'vimdoc', 'java', 'comment', 'query', 'jsdoc', 'angular' },
  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<C-space>',
      node_incremental = '<C-space>',
      scope_incremental = false,
      node_decremental = '<bs>'
    },
  },
}

local cmp = require('cmp')
cmp.setup {
  sources = cmp.config.sources {
    { name = 'nvim_lsp' },
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<Tab>'] = cmp.mapping.confirm { select = true },
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end)
  },
  { name = 'buffer' },
}

-- automatically add parenthesis after tabcompletion
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
)

local npairs = require('nvim-autopairs')
npairs.setup { check_ts = true }

require('nvim-tree').setup {
  filters = {
    dotfiles = false,
  },
}

vim.api.nvim_create_autocmd('QuitPre', {
  callback = function()
    vim.cmd 'NvimTreeClose'
  end,
})

--------------------------------------------------
-- Theme
--------------------------------------------------

opt.background = 'dark'
if vim.fn.has('termguicolors') then
  opt.termguicolors = true
end

vim.g.gruvbox_material_better_performance        = true
vim.g.gruvbox_material_disable_italic_comment    = true
vim.g.gruvbox_material_diagnostic_text_highlight = true
vim.g.gruvbox_material_foreground                = 'original'
-- whatever '234' means
vim.g.gruvbox_material_colors_override           = { fg0 = { '#89b482', '234' } }
vim.cmd 'colorscheme gruvbox-material'

--------------------------------------------------
-- Keybindings
--------------------------------------------------

local keymap = vim.keymap
keymap.set('n', '<Leader>ff', '<cmd>:Telescope find_files hidden=true<cr>')
keymap.set('n', '<Leader>fi', '<cmd>:Telescope find_files hidden=true theme=ivy<cr>')
keymap.set('n', '<Leader>fv', '<cmd>:Telescope find_files hidden=true layout_strategy=vertical<cr>')
keymap.set('n', '<Leader>fc', '<cmd>:Telescope current_buffer_fuzzy_find<cr>')
keymap.set('n', '<Leader>fg', '<cmd>:Telescope live_grep<cr>')
keymap.set('n', '<Leader>gi', '<cmd>:Telescope live_grep theme=ivy<cr>')
keymap.set('n', '<Leader>gv', '<cmd>:Telescope live_grep layout_strategy=vertical<cr>')
keymap.set('n', '<Leader>fb', '<cmd>:Telescope buffers<cr>')
keymap.set('n', '<Leader>fh', '<cmd>:Telescope help_tags<cr>')
keymap.set('n', '<Leader>a', '<cmd>:Telescope diagnostics<cr>')
keymap.set('n', '<Leader>d', '<cmd>:Telescope lsp_document_symbols<cr>')
keymap.set('n', '<Leader>gc', '<cmd>:Telescope git_commits<cr>')
keymap.set('n', '<Leader>gs', '<cmd>:Telescope git_status<cr>')
keymap.set('n', '<Leader>gb', '<cmd>:Telescope git_branches<cr>')

keymap.set('n', '<C-x>', '<cmd>:NvimTreeToggle<cr>')

keymap.set('n', '<Leader>st', '<cmd>:sp|term<cr>')
keymap.set('n', '<Leader>vt', '<cmd>:vsp|term<cr>')
keymap.set('n', '<Leader>t', '<cmd>:term<cr>')

keymap.set('n', '<Leader>e', vim.diagnostic.open_float)

--------------------------------------------------
-- Autocommands
--------------------------------------------------

local lspgroup = vim.api.nvim_create_augroup('UserLspConfig', {})

vim.api.nvim_create_autocmd('LspAttach', {
  group = lspgroup,
  callback = function(event)
    local opts = { buffer = event.buf }
    -- buffer local mappings
    keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    keymap.set('n', '<C-;>', vim.lsp.buf.code_action, opts)
    keymap.set('n', 'gr', vim.lsp.buf.rename, opts)
    keymap.set('n', 'gu', vim.lsp.buf.references, opts)
    keymap.set('n', '<Leader>fd', function()
      vim.lsp.buf.format { async = true }
      vim.print('Formatted document')
    end, opts)
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = lspgroup,
  pattern = 'html,xhtml,javascript,javascriptreact,typescript,typescriptreact,css,scss,lua',
  callback = function()
    vim.api.nvim_set_option_value('tabstop', 2, {})
    vim.api.nvim_set_option_value('shiftwidth', 2, {})
    vim.api.nvim_set_option_value('softtabstop', 2, {})
  end,
})

--------------------------------------------------
-- Lsp related
--------------------------------------------------

require('mason').setup()
require('mason-lspconfig').setup {
  -- automatic_installation = true,
}

local lspconfig = require('lspconfig')
lspconfig.ols.setup {}
lspconfig.tsserver.setup {}
lspconfig.lua_ls.setup {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      telemetry = { enable = false },
      workspace = {
        -- make the server aware of neovim runtime files
        library = vim.api.nvim_get_runtime_file('', true),
      },
    },
  },
}

--[[
lspconfig.marksman.setup{}

vim.lsp.handlers['textDocument/publishDiagnostics'] = filter_tsserver_diagnostics

-- suppress some tsserver diagnostics which cannot be fixed with an .eslintrc
local function filter_tsserver_diagnostics(_, result, ctx, config)
    if result.diagnostics == nil then
        return
    end
    -- ignore some tsserver diagnostics
    local idx = 1
    while idx <= #result.diagnostics do
        local entry = result.diagnostics[idx]
        -- codes: https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
        if entry.code == 80001 then
            -- {message = "File is a CommonJS module; it may be converted to an ES module."}
            table.remove(result.diagnostics, idx)
        else
            idx = idx + 1
        end
    end

    vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
end
]]
