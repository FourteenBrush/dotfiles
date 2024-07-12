vim.g.loaded_netrw       = true
vim.g.loaded_netrwPlugin = true
vim.g.mapleader          = ' '

local opt                = vim.opt

opt.syntax               = 'enable'
opt.mouse                = 'a'
opt.number               = true
opt.smarttab             = true
opt.expandtab            = true
opt.smartcase            = true
opt.tabstop              = 4
opt.shiftwidth           = 4
opt.splitbelow           = true
opt.splitright           = true
opt.showmode             = false
opt.foldmethod           = 'marker'
opt.linebreak            = true

--------------------------------------------------
-- Plugins
--------------------------------------------------

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
--- @diagnostic disable-next-line: undefined-field
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
  { 'hrsh7th/nvim-cmp', event = { 'InsertEnter', 'CmdlineEnter' } }, -- autocompletion
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'windwp/nvim-autopairs' },
  { 'nvim-tree/nvim-tree.lua' },
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  }
}

require('lazy').setup(plugins)

require('telescope').setup {
  defaults = {
    file_ignore_patterns = { 'node_modules', '.git' },
  },
}

--- @diagnostic disable-next-line: missing-fields
require('nvim-treesitter.configs').setup {
  ensure_installed = {
    'odin', 'lua', 'javascript', 'c', 'cpp', 'vimdoc', 'java', 'comment',
    'query', 'jsdoc', 'angular', 'rust',
  },
  highlight = { enable = true },
  indent = { enable = true },
  context_commentstring = {
    enable = true,
    autocmd = false,
  },
  autotag = { enable = true },
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

local npairs = require('nvim-autopairs')
npairs.setup { check_ts = true }

-- automatically add parenthesis after tabcompletion
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
)

require('nvim-tree').setup {
  view = {
    preserve_window_proportions = true,
  },
  filters = {
    dotfiles = false,
  },
}

-- https://github.com/nvim-tree/nvim-tree.lua/wiki/Auto-Close#ppwwyyxx
vim.api.nvim_create_autocmd('QuitPre', {
  callback = function ()
    local invalid_wins = {}
    local wins = vim.api.nvim_list_wins()

    for _, w in ipairs(wins) do
      local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
      if bufname:match('NvimTree_') ~= nil then
        table.insert(invalid_wins, w)
      end
    end

    if #invalid_wins == #wins - 1 then
      -- should quit, so we close all invalid windows
      for _, w in ipairs(invalid_wins) do
        vim.api.nvim_win_close(w, true)
      end
    end
  end,
})

require('lualine').setup {
  options = {
    theme = 'gruvbox-material',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    extensions = { 'lazy', 'mason', 'nvim-tree' },
  },
}


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

local nvim_tree_hi = {
  'NvimTreeNormal',
  'NvimTreeNormalNC',
  'NvimTreeWinSeparator',
  'NvimTreeEndOfBuffer',
}

for _, highlight in ipairs(nvim_tree_hi) do
  vim.cmd(':hi ' .. highlight .. ' guibg=none ctermbg=none')
end

vim.cmd [[ :hi NvimTreeFolderIcon guifg=#7094b4 ]]

--------------------------------------------------
-- Keybindings
--------------------------------------------------

local telescope = require("telescope.builtin")
local keymap = vim.keymap

keymap.set('n', '<leader>ff', '<cmd>:Telescope find_files hidden=true<cr>')
keymap.set('n', '<leader>fi', '<cmd>:Telescope find_files hidden=true theme=ivy<cr>')
keymap.set('n', '<leader>fv', '<cmd>:Telescope find_files hidden=true layout_strategy=vertical<cr>')
keymap.set('n', '<leader>fc', '<cmd>:Telescope current_buffer_fuzzy_find<cr>')
keymap.set('n', '<leader>fg', telescope.live_grep)
keymap.set('n', '<leader>gi', '<cmd>:Telescope live_grep theme=ivy<cr>')
keymap.set('n', '<leader>gv', '<cmd>:Telescope live_grep layout_strategy=vertical<cr>')
keymap.set('n', '<leader>fb', telescope.buffers)
keymap.set('n', '<leader>fh', telescope.help_tags)
keymap.set('n', '<leader>a', telescope.diagnostics)
keymap.set('n', '<leader>d', telescope.lsp_document_symbols)
keymap.set('n', '<leader>gc', telescope.git_commits)
keymap.set('n', '<leader>gs', telescope.git_status)
keymap.set('n', '<leader>gb', telescope.git_branches)

keymap.set('n', '<C-x>', '<cmd>:NvimTreeToggle<cr>')

keymap.set('n', '<leader>st', '<cmd>:sp|term<cr>')
keymap.set('n', '<leader>vt', '<cmd>:vsp|term<cr>')
keymap.set('n', '<leader>t', '<cmd>:term<cr>')

keymap.set('n', '<leader>e', vim.diagnostic.open_float)

keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', {
  desc = 'Exit terminal mode',
})

--------------------------------------------------
-- Autocommands
--------------------------------------------------

local lspgroup = vim.api.nvim_create_augroup('UserLspConfig', {})

vim.api.nvim_create_autocmd('LspAttach', {
  group = lspgroup,
  callback = function(args)
    local opts = { buffer = args.buf }

    vim.lsp.inlay_hint.enable(args.buf, true)

    -- buffer local mappings
    keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    keymap.set('n', '<C-;>', vim.lsp.buf.code_action, opts)
    keymap.set('n', 'gr', vim.lsp.buf.rename, opts)
    keymap.set('n', 'gu', vim.lsp.buf.references, opts)
    keymap.set('n', '<leader>fd', function()
      vim.lsp.buf.format { async = true }
      vim.print('Formatted document')
    end, opts)
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = lspgroup,
  pattern = 'html,xhtml,javascript,javascriptreact,typescript,typescriptreact,css,scss,lua',
  callback = function()
    vim.api.nvim_set_option_value('tabstop', 2, { scope = 'local' })
    vim.api.nvim_set_option_value('shiftwidth', 2, { scope = 'local' })
    vim.api.nvim_set_option_value('softtabstop', 2, { scope = 'local' })
  end,
})

--------------------------------------------------
-- Lsp related
--------------------------------------------------

require('mason').setup()
require('mason-lspconfig').setup {
  automatic_installation = true,
}

local lspconfig = require('lspconfig')
lspconfig.ols.setup {}
lspconfig.tsserver.setup {
  init_options = {
    preferences = {
      includeInlayParameterNameHints = 'all',
    },
  },
}
lspconfig.lua_ls.setup {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      telemetry = { enable = false },
      workspace = {
        -- make the server aware of neovim runtime files
        library = vim.api.nvim_get_runtime_file('', true),
      },
      diagnostics = {
        globals = { 'vim' },
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
