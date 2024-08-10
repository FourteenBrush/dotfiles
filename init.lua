vim.g.loaded_netrw       = true
vim.g.loaded_netrwPlugin = true
vim.g.mapleader          = ' '
vim.g.maplocalleader     = ' '

local opt                = vim.opt

opt.syntax               = 'enable'
opt.background           = 'dark'
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
-- opt.inccommand           = 'split'
-- number of lines to keep above and below cursor when f.e. jumping
opt.scrolloff            = 2

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
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate', event = { 'BufReadPre', 'BufNewFile' } },
  { 'neovim/nvim-lspconfig' },
  { 'williamboman/mason.nvim' },
  { 'williamboman/mason-lspconfig.nvim' },
  -- { 'sainnhe/gruvbox-material' },
  -- { 'sainnhe/everforest', priority = 1000 },
  { 'Shatur/neovim-ayu' },
  { 'hrsh7th/nvim-cmp', event = { 'InsertEnter', 'CmdlineEnter', 'BufReadPost' } }, -- autocompletion
  { 'onsails/lspkind.nvim' }, -- fancy icons for nvim-cmp
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
  },
  { 'akinsho/toggleterm.nvim', config = true },
  { 'https://github.com/junegunn/vim-easy-align.git' },
}

require('lazy').setup(plugins)

local previewers= require('telescope.previewers')
local Job = require('plenary.job')

local new_maker = function (filepath, bufnr, opts)
  filepath = vim.fn.expand(filepath)
  Job:new {
    command = 'file',
    args = { '--mime-type', '-b', filepath },
    on_exit = function (j)
      local mime_type = vim.split(j:result()[1], '/')[1]
      if mime_type == 'text' then
        previewers.buffer_previewer_maker(filepath, bufnr, opts)
      else
        vim.schedule(function ()
          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'BINARY' })
        end)
      end
    end
  }:sync()
end

require('telescope').setup {
  defaults = {
    buffer_previewer_maker = new_maker,
    file_ignore_patterns = { 'node_modules', '.git/' },
  },
}

--- @diagnostic disable-next-line: missing-fields
require('nvim-treesitter.configs').setup {
  ensure_installed = {
    'odin', 'lua', 'javascript', 'c', 'cpp', 'vimdoc', 'java', 'comment',
    'query', 'jsdoc', 'angular', 'rust', -- 'clangd',
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
local lspkind = require('lspkind')

cmp.setup {
  --[[
  window = {
    completion = cmp.config.window.bordered(),
  },
  --]]
  formatting = {
    format = lspkind.cmp_format(),
  },
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
  view = { preserve_window_proportions = true },
  filters = { dotfiles = false },
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
    theme = 'ayu',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    extensions = { 'lazy', 'mason', 'nvim-tree' },
  },
}

require('toggleterm').setup {
  -- there's an mapping timeout issue with this approach
  -- open_mapping = '<leader>tt',
  size = function (term)
    if term.direction == 'horizontal' then
      return 15
    elseif term.direction == 'vertical' then
      return vim.o.columns * 0.4
    end
  end,
}



--------------------------------------------------
-- Theme
--------------------------------------------------

vim.cmd.colorscheme('ayu-dark')
-- vim.cmd [[ :hi NvimTreeFolderIcon guifg=#7094b4 ]]

--------------------------------------------------
-- Keybindings
--------------------------------------------------

local keymap = vim.keymap

-- remap splits navigation to just CTRL + hjkl
keymap.set('n', '<C-h>', '<C-w>h')
keymap.set('n', '<C-j>', '<C-w>j')
keymap.set('n', '<C-k>', '<C-w>k')
keymap.set('n', '<C-l>', '<C-w>l')

-- make adjusting split sizes a bit more friendly
keymap.set('n', '<C-Left>', '<cmd>:vert res +3<cr>')
keymap.set('n', '<C-Right>', '<cmd>:vert res -3<cr>')
keymap.set('n', '<C-Up>', '<cmd>:res +3<cr>')
keymap.set('n', '<C-Down>', '<cmd>:res +3<cr>')

local telescope = require('telescope.builtin')

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

-- tt :vnew term://fish

keymap.set('n', '<leader>tt', '<cmd>exe v:count . "ToggleTerm"<cr>')
keymap.set('n', '<leader>tv', '<cmd>:ToggleTerm direction=vertical<cr>')
keymap.set('n', '<leader>tf', '<cmd>exe v:count . "ToggleTerm direction=float"<cr>')

keymap.set('n', '<leader>e', vim.diagnostic.open_float)

keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', {
  desc = 'Exit terminal mode',
})

keymap.set('x', 'ga', '<Plug>(EasyAlign)', { silent = true })
keymap.set('n', 'ga', '<Plug>(EasyAlign)', { silent = true })

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
    local opts = { scope = 'local' }
    vim.api.nvim_set_option_value('tabstop', 2, opts)
    vim.api.nvim_set_option_value('shiftwidth', 2, opts)
    vim.api.nvim_set_option_value('softtabstop', 2, opts)
  end,
})

--------------------------------------------------
-- Lsp related
--------------------------------------------------

require('mason').setup {
  opts = {
    ensure_installed = {
      'clangd',
    },
  },
}
require('mason-lspconfig').setup {
  automatic_installation = true,
}

local lspconfig = require('lspconfig')
lspconfig.ols.setup {}
lspconfig.pyright.setup {}
lspconfig.clangd.setup {
}
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
