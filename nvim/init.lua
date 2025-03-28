vim.g.loaded_netrw          = true
vim.g.loaded_netrwPlugin    = true
vim.g.mapleader             = ' '
vim.g.maplocalleader        = ' '
vim.g.nvim_tree_group_empty = 1
vim.g.base46_cache          = vim.fn.stdpath('data') .. '/nvchad/base46/'
vim.g.copilot_no_tab_map    = true

local opt                   = vim.opt
opt.syntax                  = 'enable'
opt.background              = 'dark'
opt.mouse                   = 'a'
opt.number                  = true

opt.smarttab                = true
-- use the appropriate number of spaces to insert a tab
opt.expandtab               = true
-- number of spaces that a tab counts for
opt.tabstop                 = 4
-- number of spaces to use for each step of (auto)indent
opt.shiftwidth              = 4

opt.smartcase               = true
opt.splitbelow              = true
opt.splitright              = true
opt.showmode                = false
opt.foldmethod              = 'marker'
opt.linebreak               = true
-- opt.inccommand           = 'split'
-- number of lines to keep above and below cursor when f.e. jumping
opt.scrolloff               = 2
-- case insentive search unless \C or capital in search
opt.ignorecase              = true
opt.smartcase               = true
-- persistent undo
opt.undofile                = true

--------------------------------------------------
-- Plugins
--------------------------------------------------

local lazypath              = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

--- @diagnostic disable-next-line: undefined-field
if not vim.uv.fs_stat(lazypath) then
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

local is_nixos = vim.fn.isdirectory('/nix/store')
local lsp_clients = { 'clangd', 'pyright', 'lua_ls', 'zls', 'typescript-language-server', 'bashls', 'prismals', 'nixd', 'jdtls' }
-- filter oit problematic lsp servers, which usually package themselves as a .so; assume the wrapped version
-- is used instead on nixos
if not is_nixos then
  table.insert(lsp_clients, 'lua_ls')
end

local lombok_path = vim.fn.stdpath('data') .. '/mason/packages/jdtls/lombok-patched.jar'

require('lazy').setup {
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate', event = { 'BufReadPre', 'BufNewFile' } },
  { 'neovim/nvim-lspconfig' },
  {
    'williamboman/mason.nvim',
    opts = {
      opts = {
        ensure_installed = lsp_clients,
      },
    },
  },
  { 'williamboman/mason-lspconfig.nvim' },
  { 'hrsh7th/nvim-cmp', event = { 'CmdlineEnter', 'BufReadPost' } }, -- autocompletion
  {
    'L3MON4D3/LuaSnip',
    build = 'make install_jsregexp',
    dependencies = { 'rafamadriz/friendly-snippets' },
  },
  { 'saadparwaiz1/cmp_luasnip' },
  { 'onsails/lspkind.nvim' }, -- fancy vscode like icons
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'windwp/nvim-autopairs', opts = { check_ts = true } },
  { 'nvim-tree/nvim-tree.lua' },
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope-file-browser.nvim' },
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme = 'gruvbox-material',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        extensions = { 'lazy', 'mason', 'nvim-tree' },
      },
    },
  },
  { 'akinsho/toggleterm.nvim' },
  { 'https://github.com/junegunn/vim-easy-align.git' },
  { 'NvChad/base46', build = function()
    require('base46').load_all_highlights()
    end,
  },
  { 'NvChad/ui',              lazy = false },
  { 'lewis6991/gitsigns.nvim', config = true },
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    keys = {
      { '<Leader>s', mode = { 'n', 'x', 'o' }, function() require('flash').jump() end },
      { '<Leader>S', mode = { 'n', 'x', 'o' }, function() require('flash').treesitter() end },
      { '<Leader>R', mode = { 'o', 'x' },      function() require('flash').treesitter_search() end },
    },
  },
  { 'windwp/nvim-ts-autotag', config = true },
  {
    'stevearc/conform.nvim', opts = {
      formatters_by_ft = {
        javascript = { 'prettierd', 'prettier', stop_after_first = true },
      },
    },
  },
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },
  { 'github/copilot.vim' },
  {
    'mfussenegger/nvim-jdtls',
    init = function ()
      -- download the lombok jar if not present (the shipped one seems to do nothing)
      -- for some stupid reason the shipped one is still needed as an agent, otherwise there are still errors..
      -- so dont ask me about the state of either of those jars.
      -- It could happen sometimes that errors concerning lombok generated code appear
      -- but an :e usually makes them go away???
      -- Also jdtls seems to be spawned twice?
      if vim.fn.filereadable(lombok_path) == 0 then
        vim.print('Downloading actually working lombok jar')
        vim.fn.system { 'curl', '-L', '-o', lombok_path, 'https://projectlombok.org/downloads/lombok.jar' }
      end
    end
  },
}

--------------------------------------------------
--- Telescope.nvim
--------------------------------------------------

--[[
local previewers= require('telescope.previewers')
local Job = require('plenary.job')

local function new_maker (filepath, bufnr, opts)
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
]] --

local telescope = require('telescope')
local actions = require('telescope.actions')
telescope.setup {
  defaults = {
    -- buffer_previewer_maker = new_maker,
    file_ignore_patterns = { 'node_modules', '.git/' },
    mappings = {
      i = {
        ['<C-h>'] = actions.select_horizontal,
      },
    },
  },
  extensions_list = { 'themes', 'file_browser' },
  -- pickers = {
  --   find_files = {
  --     mappings = {
  --       i = {
  --         ['<C-h>'] = 'select_horizontal',
  --       },
  --     },
  --   },
  -- },
}
-- TODO: use https://github.com/NvChad/ui/blob/dbdd2cfa7b6267e007e0b87ed7e2ea5c6979ef22/lua/telescope/_extensions/themes.lua#L82
telescope.load_extension('themes')
pcall(telescope.load_extension, 'file_browser')

--- @diagnostic disable-next-line: missing-fields
require('nvim-treesitter.configs').setup {
  ensure_installed = {
    'odin', 'lua', 'javascript', 'c', 'cpp', 'vimdoc', 'java', 'comment', 'query', 'jsdoc', 'dart',
    'angular', 'rust', 'python', 'javascript', 'diff', 'zig', 'go', 'bash', 'xml', 'typescript',
    'css', 'fish', 'make', 'tsx', 'graphql', 'prisma', 'terraform',
  },
  highlight = { enable = true },
  indent = { enable = true },
  -- default keybinding: gcc
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

local luasnip = require('luasnip')
require('luasnip.loaders.from_vscode').lazy_load {}

local cmp = require('cmp')

cmp.setup {
  enabled = function()
    -- keep command mode completion enabled when cursor is in a comment
    if vim.api.nvim_get_mode().mode == 'c' then
      return true
    end

    local context = require('cmp.config.context')
    return not context.in_treesitter_capture('comment') and not context.in_syntax_group('Comment')
  end,
  window = {
    -- completion = cmp.config.window.bordered(),
    completion = {
      winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,Search:None',
      col_offset = -3,
      side_padding = 0,
    },
  },
  formatting = {
    fields = { 'kind', 'abbr', 'menu' },
    format = function(entry, vim_item)
      local kind = require('lspkind').cmp_format { mode = 'symbol_text', maxwidth = 50 } (entry, vim_item)
      local strings = vim.split(kind.kind, '%s', { trimempty = true })
      kind.kind = ' ' .. (strings[1] or '') .. ' '
      kind.menu = '    (' .. (strings[2] or '') .. ')'
      return kind
    end
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, { name = 'buffer' }),
  snippet = {
    expand = function(args)
      -- vim.notify("expanding snippet in snippet.expand")
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    -- TODO: conflicting mapping with node_incremental
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-d>'] = cmp.mapping.scroll_docs(2),
    ['<C-u>'] = cmp.mapping.scroll_docs(-2),
    ['Up'] = cmp.mapping.select_prev_item(),
    ['Down'] = cmp.mapping.select_next_item(),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if not cmp.visible() then
        fallback()
      elseif luasnip.expand_or_jumpable() then
        local active = cmp.get_selected_entry()
        -- only allow expanding or jumping if a snippet is actually selected in the menu
        -- luasnip.expandable() somehow returns true if there is _any_ snippet in the completion menu
        if active or luasnip.jumpable() then
          cmp.confirm { select = true }
        else
          cmp.select_next_item()
        end
      else
        cmp.confirm { select = true }
      end
    end),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end),
  },
}

-- automatically add parenthesis on tabcompletion
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
)

require('nvim-tree').setup {
  view = { preserve_window_proportions = false },
  -- TODO: set back to true
  -- TODO: resize manually to proper size
  -- TODO: some issue when opening another file, the panel gets resized
  actions = { open_file = { resize_window = true } },
  filters = { git_ignored = false },
  renderer = {
    group_empty = true,
    highlight_opened_files = 'name',
    indent_markers = {
      enable = true,
    },
    icons = {
      show = { folder_arrow = false },
    },
  },
}

-- https://github.com/nvim-tree/nvim-tree.lua/wiki/Auto-Close#ppwwyyxx
vim.api.nvim_create_autocmd('QuitPre', {
  callback = function()
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

require('toggleterm').setup {
  -- there's an mapping timeout issue with this approach
  -- open_mapping = '<leader>tt',
  size = function(term)
    if term.direction == 'horizontal' then
      return 15
    elseif term.direction == 'vertical' then
      return vim.o.columns * 0.4
    end
  end,
  shade_terminals = false,
  highlights = {
    -- Normal = { guibg = '#ffffff' --[[  '#1e2122' ]], guifg = '#ffffff' },
  },
}

local harpoon = require('harpoon')
harpoon:setup {}

local conf = require('telescope.config').values
local function toggle_telescope(harpoon_files)
  local file_paths = {}
  for _, item in ipairs(harpoon_files.items) do
    table.insert(file_paths, item.value)
  end

  require('telescope.pickers').new({}, {
    prompt_title = "Harpoon",
    finder = require('telescope.finders').new_table {
      results = file_paths,
    },
    previewer = conf.file_previewer {},
    sorter = conf.generic_sorter {},
  }):find()
end

vim.keymap.set('n', '<Leader>e', function ()
  toggle_telescope(harpoon:list())
end)

--------------------------------------------------
-- Theme
--------------------------------------------------

--[[
require('ayu').setup {
  -- disable italic for comments
  overrides = function()
    return { Comment = { fg = colors.comment } }
  end,
}
vim.cmd.colorscheme('ayu-dark')
]] --
-- vim.cmd [[ :hi NvimTreeFolderIcon guifg=#7094b4 ]]
-- TODO: which of this crap do we actually need?
local theme_integrations = {
  'defaults', 'statusline', 'git', 'cmp', 'syntax', 'lsp', 'treesitter', 'nvimtree', 'statusline', 'telescope', --[[ 'term' --]] }
for _, integration in ipairs(theme_integrations) do
  dofile(vim.g.base46_cache .. integration)
end

--------------------------------------------------
-- Keybindings
--------------------------------------------------

local keymap = vim.keymap

keymap.set('n', '<Esc>', '<cmd>nohlsearch<cr>')
-- remap splits navigation to just CTRL + hjkl
keymap.set('n', '<C-h>', '<C-w>h')
keymap.set('n', '<C-j>', '<C-w>j')
keymap.set('n', '<C-k>', '<C-w>k')
keymap.set('n', '<C-l>', '<C-w>l')

-- make adjusting split sizes a bit more friendly
keymap.set('n', '<C-Left>', '<cmd>:vert res -3<cr>')
keymap.set('n', '<C-Right>', '<cmd>:vert res +3<cr>')
keymap.set('n', '<C-Up>', '<cmd>:res +3<cr>')
keymap.set('n', '<C-Down>', '<cmd>:res +3<cr>')

local builtin = require('telescope.builtin')

keymap.set('n', '<leader>ff', '<cmd>:Telescope find_files hidden=true<cr>')
keymap.set('n', '<leader>fi', '<cmd>:Telescope find_files hidden=true theme=ivy<cr>')
keymap.set('n', '<leader>b', '<cmd>:Telescope file_browser<cr>')
keymap.set('n', '<leader>fv', '<cmd>:Telescope find_files hidden=true layout_strategy=vertical<cr>')
keymap.set('n', '<leader>fc', builtin.current_buffer_fuzzy_find)
keymap.set('n', '<leader>fg', builtin.live_grep)
keymap.set('n', '<leader>gi', '<cmd>:Telescope live_grep theme=ivy<cr>')
keymap.set('n', '<leader>gv', '<cmd>:Telescope live_grep layout_strategy=vertical<cr>')
keymap.set('n', '<leader>fb', builtin.buffers)
keymap.set('n', '<leader>fh', builtin.help_tags)
-- keymap.set('n', '<leader>a', builtin.diagnostics)
keymap.set('n', '<leader>d', builtin.lsp_document_symbols)
keymap.set('n', '<leader>gc', builtin.git_commits)
keymap.set('n', '<leader>gs', builtin.git_status)
keymap.set('n', '<leader>gb', builtin.git_branches)

keymap.set('n', '<C-x>', '<cmd>:NvimTreeToggle<cr>')

local tabufline = require('nvchad.tabufline')
require('nvchad.colorify')
keymap.set('n', '<Leader>x', tabufline.close_buffer)
keymap.set('n', '<Leader><Left>', tabufline.prev)
keymap.set('n', '<Leader><Right>', tabufline.next)
keymap.set('n', '<Leader>lx', function() tabufline.closeBufs_at_direction("left") end)
keymap.set('n', '<Leader>rx', function() tabufline.closeBufs_at_direction("right") end)
keymap.set('n', '<Leader>ax', function() tabufline.closeAllBufs(false) end)

-- tt :vnew term://fish

keymap.set('n', '<leader>tt', '<cmd>exe v:count . "ToggleTerm"<cr>')
keymap.set('n', '<leader>tv', '<cmd>exe v:count . "ToggleTerm direction=vertical"<cr>')
keymap.set('n', '<leader>th', '<cmd>exe v:count . "ToggleTerm direction=horizontal"<cr>')
keymap.set('n', '<leader>tf', '<cmd>exe v:count . "ToggleTerm direction=float"<cr>')

-- keymap.set('n', '<leader>e', vim.diagnostic.open_float)

keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', {
  desc = 'Exit terminal mode',
})

keymap.set('x', 'ga', '<Plug>(EasyAlign)', { silent = true })
keymap.set('n', 'ga', '<Plug>(EasyAlign)', { silent = true })

keymap.set('n', '<Leader>a', function() harpoon:list():add() end)
keymap.set('n', '<Leader>r', function() harpoon:list():remove() end)
keymap.set('n', '<Leader>h', function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end)
keymap.set('n', '<Leader>c', function() harpoon:list():clear() end)

--------------------------------------------------
-- Autocommands
--------------------------------------------------

local lspgroup = vim.api.nvim_create_augroup('UserLspConfig', {})

vim.api.nvim_create_autocmd('LspAttach', {
  group = lspgroup,
  callback = function(args)
    local opts = { buffer = args.buf }

    -- vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })

    -- buffer local mappings
    keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    keymap.set('n', '<C-;>', vim.lsp.buf.code_action, opts)
    keymap.set('n', 'gr', require('nvchad.lsp.renamer'), opts)
    keymap.set('n', 'gu', vim.lsp.buf.references, opts)
    keymap.set('n', '<leader>fd', function()
      require('conform').format {
        lsp_format = 'fallback',
        callback = function()
          vim.print('Formatted document')
        end,
      }
    end, opts)
  end,
})

vim.api.nvim_create_autocmd('BufEnter', {
  group = lspgroup,
  pattern = { '*.html', '*.xhtml', '*.js', '*.jsx', '*.ts', '*.tsx', '*.css', '*.scss', '*.lua', '*.json', '*.nix', '*.py' },
  callback = function(event)
    local formatters_for_buf = require('conform').list_formatters(event.buf)
    if #formatters_for_buf > 0 then
      return
    end -- do not override config from formatter

    for _, key in ipairs({ 'tabstop', 'shiftwidth', 'softtabstop' }) do
      vim.api.nvim_set_option_value(key, 2, { buf = event.buf })
    end
  end,
})

local home = os.getenv 'HOME'

local workspace_path = home .. '/.local/share/nvim/jdtls_workspace/'
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = workspace_path .. project_name

local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

local function start_jdtls()
  local jdtls_opts = {
    capabilities = capabilities,
    -- cmd = {
    --   'jdtls',
    --   '--jvm-arg=-Declipse.application=org.eclipse.jdt.ls.core.id1',
    --   '--jvm-arg=-Dosgi.bundles.defaultStartLevel=4',
    --   '--jvm-arg=-Declipse.product=org.eclipse.jdt.ls.core.product',
    --   '--jvm-arg=-Dlog.protocol=true',
    --   '--jvm-arg=-Dlog.level=ALL',
    --   '--jvm-arg=-Xmx1g',
    --   '--jvm-arg=--add-modules=ALL-SYSTEM',
    --   '--jvm-arg=--add-opens',
    --   '--jvm-arg=java.base/java.util=ALL-UNNAMED',
    --   '--jvm-arg=--add-opens',
    --   '--jvm-arg=java.base/java.lang=ALL-UNNAMED',
    --   '--jvm-arg=--add-modules=java.compiler',
    --   '--jvm-arg=-javaagent:' .. home .. '/.local/share/nvim/mason/packages/jdtls/lombok.jar',
    --   '--jvm-arg=-Dlombok.verbose=true',
    --   -- '--jvm-arg=-Xbootclasspath/a:' .. home .. '/.local/share/nvim/mason/packages/jdtls/lombok.jar',
    --   '-configuration',
    --   home .. '/.local/share/nvim/mason/packages/jdtls/config_linux',
    --   '-data',
    --   workspace_dir,
    -- },
    cmd = {
      'java',
      '-Declipse.application=org.eclipse.jdt.ls.core.id1',
      '-Dosgi.bundles.defaultStartLevel=4',
      '-Declipse.product=org.eclipse.jdt.ls.core.product',
      '-Dlog.protocol=true',
      '-Dlog.level=ALL',
      '-Xmx1g',
      '--add-modules=ALL-SYSTEM',
      '--add-opens', 'java.base/java.util=ALL-UNNAMED',
      '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
      '-javaagent:' .. home .. '/.local/share/nvim/mason/packages/jdtls/lombok.jar',
      -- '-javaagent:' .. home .. '/.local/share/nvim/mason/packages/jdtls/lombok-patched.jar',
      '-jar',
      vim.fn.glob(home .. '/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar'),
      '-configuration',
      home .. '/.local/share/nvim/mason/packages/jdtls/config_linux',
      '-data', workspace_dir,
    },
    settings = {
      java = {
        configuration = {
          updateBuildConfiguration = 'interactive',
        },
        inlayHints = {
          parameterNames = { enabled = 'all' },
        },
      },
      references = {
        includeDecompiledSources = true,
      },
      referenceCodeLens = { enabled = true },
    },
  }

  require('jdtls').start_or_attach(jdtls_opts)
end

vim.api.nvim_create_autocmd('FileType', {
  group = lspgroup,
  pattern = 'java',
  callback = function()
    if vim.env.JDTLS_JVM_ARGS == nil then
      -- cant really override the env for the spawned lsp clients so require the parent shell to do that
      vim.notify(
        'env var JDTLS_JVM_ARGS not set, lombok will not work correctly; set it to -javaagent:' .. lombok_path,
        vim.log.levels.WARN)
    end

    start_jdtls()
  end,
})

--------------------------------------------------
-- Lsp related
--------------------------------------------------

local lspconfig = require('lspconfig')

-- setup manually installed lsp servers
lspconfig.ols.setup {}
if is_nixos then
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
end
lspconfig.nixd.setup {
  settings = {
    nixd = {
      nixpkgs = { expr = 'import <nixpkgs> {}' },
      formatting = { command = { 'nixfmt-rfc-style' } },
      options = {
        home_manager = {
          expr = '(builtins.getFlake "' .. home .. '/.config/home-manager/flake.nix").homeConfigurations.cluster2.options',
        },
      },
    },
  },
}

local handlers = {
  function(server_name)
    lspconfig[server_name].setup {
      capabilities = capabilities,
    }
  end,

  -- ['lua_ls'] = function()
  --   lspconfig.lua_ls.setup {
  --     settings = {
  --       Lua = {
  --         runtime = { version = 'LuaJIT' },
  --         telemetry = { enable = false },
  --         workspace = {
  --           -- make the server aware of neovim runtime files
  --           library = vim.api.nvim_get_runtime_file('', true),
  --         },
  --         diagnostics = {
  --           globals = { 'vim' },
  --         },
  --       },
      -- },
    -- }
  -- end
}

require('mason-lspconfig').setup {
  automatic_installation = true,
  handlers = handlers,
}

--[[
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
--]]
