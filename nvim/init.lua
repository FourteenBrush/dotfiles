vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- show file preview (P) vertically split
vim.g.netrw_preview = 1
vim.g.netrw_alto = 0 -- 0 = split above, 1 = split below
-- file size in human readable 1024 bytes base
vim.g.netrw_sizestyle = "H"

local opt = vim.opt
opt.syntax = "enable"
opt.termguicolors = true
opt.background = "dark"
opt.mouse = "a"
opt.number = true
-- open new windows on the right of the current one (also implicitly switches to it)
opt.splitright = true

opt.cursorline = true -- highlight current line
opt.cursorlineopt = "number" -- only show number
opt.list = true
opt.lcs:append("space:∙") -- show spaces as dots

opt.smarttab = true
-- use the appropriate number of spaces to insert a tab
opt.expandtab = true
-- number of spaces that a tab accounts for
opt.tabstop = 4
-- number of spaces to use for each step of (auto)indent
opt.shiftwidth = 4

vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "html", "xhtml", "js", "jsx", "ts", "typescriptreact", "gleam",
    "css", "scss", "lua", "json", "nix", "py", "dart", "fish", "sh", "qml",
  },
  callback = function()
    local optl = vim.opt_local
    optl.tabstop = 2
    optl.shiftwidth = 2
    optl.softtabstop = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "json",
  callback = function()
    -- theoretically comments are not supported in .json files, but just
    -- use "//" to comment regardless
    vim.bo.commentstring = "// %s"
  end
})

vim.api.nvim_create_user_command("ToggleVirtualLines", function ()
  vim.diagnostic.config { virtual_lines = not vim.diagnostic.config().virtual_lines }
end, {})

opt.smartcase = true
opt.linebreak = true
-- number of lines to keep above and below cursor when f.e. jumping
opt.scrolloff = 2
opt.ignorecase = true
-- case insentive search unless \C or capital in search
opt.smartcase = true
-- persistent undo
opt.undofile = true
opt.splitbelow = true

vim.pack.add {
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/dmtrKovalenko/fff.nvim",
  "https://github.com/nvim-mini/mini.nvim",
}

require("mini.pairs").setup {}
require("mini.icons").setup {}
MiniIcons.tweak_lsp_kind()
MiniIcons.mock_nvim_web_devicons()


vim.api.nvim_create_autocmd("PackChanged", {
  callback = function (event)
    local name, kind = event.data.spec.name, event.data.kind
    if name == "fff.nvim" and kind == "update" then
      require("fff.download").download_or_build_binary()
    end
  end
})

-- move from vertical to horizontal layout at >= x cols
local FLEX_BREAKPOINT_COLS = 190
require("fff").setup {
  lazy_sync = false,
  layout = {
    -- width = 0.85,
    preview_position = function(vpwidth, _)
      return vpwidth > FLEX_BREAKPOINT_COLS and "right" or "top"
    end,
  },
  keymaps = {
    move_up = { "<Up>", "<C-u>" },
  },
}

vim.pack.add {
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
}
require("telescope").setup {
  defaults = {
    file_ignore_patterns = { "node_modules", ".git/" },
    mappings = {
      -- clear prompt on ctrl-c
      i = { ["<C-c>"] = false }
    },
    -- dynamically switch between horizontal and vertical layout
    layout_strategy = "flex",
    layout_config = {
      width = 0.85, -- default seems to be 80%
      flex = {
        flip_columns = FLEX_BREAKPOINT_COLS,
      },
    },
  },
}
vim.pack.add { "https://github.com/catgoose/nvim-colorizer.lua" }
require("colorizer").setup {
  options = {
    parsers = { css = true },
    display = {
      mode = "virtualtext", -- display small cube next to line
      virtualtext = { position = "after" },
    },
  },
  -- "css", "javascript", "typescript", "javascriptreact", "typescriptreact",
}

--------------------
--- Colorscheme
--------------------

vim.pack.add { "https://github.com/scottmckendry/cyberdream.nvim" }
local comp_menu_bg = "#212426"
require("cyberdream").setup {
  saturation = 0.9,
  highlights = {
    -- make line number of current line more visible
    CursorLineNr = { fg = "#F8FAFC" },
    -- horizontal split separator essentially
    StatusLine = { bg = "#151618" },

    BlinkCmpMenu = { bg = comp_menu_bg },
    BlinkCmpMenuItem = { bg = comp_menu_bg },
    BlinkCmpLabel = { bg = comp_menu_bg },
    BlinkCmpSignatureHelp = { bg = "#2a2e30" },
    BlinkCmpDoc = { bg = comp_menu_bg },
    BlinkCmpLabelDetail = { bg = comp_menu_bg },
    BlinkCmpLabelDescription = { bg = comp_menu_bg },
    BlinkCmpMenuBorder = { fg = "#3E4C6D" },

    -- keyword.type is italic for whatever reason, override it
    ["@keyword.type"] = { fg = "#f6bb66", italic = false },
  },
}
vim.cmd.colorscheme("cyberdream")

--------------------
--- Keybindings
--------------------

local map = vim.keymap.set
local telescope = require("telescope.builtin")
map("n", "<Leader>ff", require("fff").find_files)
map("n", "<C-p>", require("fff").find_files) -- mimic Zed project search

map("n", "g/", telescope.live_grep) -- mimic Zed grep, requires ripgrep
map("n", "<Leader>gb", telescope.current_buffer_fuzzy_find)

map("n", "<C-s>", function() telescope.buffers { layout_strategy = "center" } end)
map("n", "<Leader>b", function() telescope.buffers { layout_strategy = "center" } end)
map("n", "gs", telescope.lsp_document_symbols)
map("n", "gS", telescope.lsp_workspace_symbols)
map("n", "<Leader>gc", telescope.git_commits)
map("n", "<Leader>gd", telescope.git_status)

map("n", "<Esc>", "<cmd>noh<cr>")
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

--------------------
--- LSP
--------------------

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function()
    vim.diagnostic.config { virtual_lines = true }

    map("n", "gd", vim.lsp.buf.definition)
    map("n", "gD", vim.lsp.buf.declaration)
    map("n", "gi", vim.lsp.buf.implementation)
    map("n", "<C-;>", vim.lsp.buf.code_action)
  end,
})

vim.pack.add {
  -- NOTE: master (default for now) is not guaranteed to be compatible with nvim 0.12,
  -- also the main branch is a total rewrite of the plugin and has a totally different api:
  -- https://github.com/nvim-treesitter/nvim-treesitter/issues/4767
  -- https://github.com/nvim-treesitter/nvim-treesitter/discussions/7901
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" }
}

local treesitter = require("nvim-treesitter")
treesitter.setup()
local ensure_installed = {
  "odin", "lua", "javascript", "c", "cpp", "vimdoc", "java", "comment", "query", "jsdoc", "dart",
  "angular", "rust", "python", "javascript", "diff", "zig", "go", "bash", "xml", "typescript",
  "css", "fish", "make", "tsx", "graphql", "prisma", "terraform", "yaml", "qmljs", "gleam", "hyprlang",
}
treesitter.install(ensure_installed)

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function(_)
      -- syntax highlighting provided by neovim
      -- we use a pcall to ingore errors "Parser could not be created for language <something>"
      -- because the language is not built in (e.g. TelescopePrompt, minideps-*, fff_list)
      local start_ok = pcall(vim.treesitter.start)
      if start_ok then
        -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        -- vim.wo.foldmethod = 'expr'
        -- indentation, provided by nvim-treesitter
        -- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end,
})

-- --- @diagnostic disable-next-line: missing-fields
-- require("nvim-treesitter.configs").setup {
--   ensure_installed = ensure_installed,
--   -- automatically install parsers when entering buffer
--   auto_install = true,
--   highlight = { enable = true },
--   indent = { enable = true },
--   textobjects = { enable = true },
-- }

vim.pack.add {
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
}
-- NOTE: dartls and nixd are gone from the registry for some reason
local lsp_clients = { "pyright", "zls", "ts_ls", "bashls", "prismals", "jdtls", "qmlls" }
-- FIXME: not correct due to the nix pkg manager creating these paths on non-nixos systems too
local is_nixos = vim.fn.isdirectory("/nix/store")
local is_windows = vim.fn.has("win32") and true or false

local home = os.getenv("HOME")
local user = os.getenv("USER")
-- since lua 5.2 unpack is now table.unpack
if not table.unpack then
    table.unpack = unpack
end
-- filter out problematic lsp servers, which usually package themselves as a .so; assume the wrapped version
-- is used instead on nixos
if is_nixos == 0 then
  lsp_clients = { "lua_ls", "clangd", table.unpack(lsp_clients) }
end

-- lsp registries
require("mason").setup {}

-- NOTE: requires mason to be setup first, in order to populate env var $MASON
local jdtls_folder = vim.fn.expand("$MASON/packages/jdtls")

local lsp_configs = {
  -- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/jdtls.lua
  jdtls = {
    cmd = {
      "java",
      "-Declipse.application=org.eclipse.jdt.ls.core.id1",
      "-Dosgi.bundles.defaultStartLevel=4",
      "-Declipse.product=org.eclipse.jdt.ls.core.product",
      "-Dlog.protocol=true",
      -- "-Dlog.level=ALL",
      "-Xmx4g",
      "--add-modules=ALL-SYSTEM",
      "--add-opens", "java.base/java.util=ALL-UNNAMED",
      "--add-opens", "java.base/java.lang=ALL-UNNAMED",
      "-javaagent:" .. jdtls_folder .. "/lombok.jar",

      -- The jar file is located where jdtls was installed
      "-jar", vim.fn.glob(jdtls_folder .. "/plugins/org.eclipse.equinox.launcher_*.jar"),

      -- The configuration for jdtls is also placed where jdtls was installed. This will
      -- need to be updated depending on your environment
      "-configuration", jdtls_folder .. (is_windows and "/config_win" or "/config_linux"),
      "-data", jdtls_folder .. "/workspace",
    },
  },
  qmlls = {
    cmd = { "qmlls", "-E" },
  },
  nixd = {
    settings = {
      nixd = {
        nixpkgs = { expr = 'import <nixpkgs> {}' },
        formatting = { command = { 'nixfmt-rfc-style' } },
        options = {
          home_manager = {
            expr = '(builtins.getFlake "' .. home .. '/.config/home-manager/flake.nix").homeConfigurations.' .. user .. '.options',
          },
        },
      },
    },
  },
  lua_ls = {
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
  },
}

require("mason-lspconfig").setup {
  ensure_installed = lsp_clients,
  automatic_installation = true,
}

-- lspconfig only used as config repo, actual configuration happens through vim.lsp
vim.pack.add {
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/Saghen/blink.lib",
  "https://github.com/Saghen/blink.cmp",
}
local blink_cmp = require("blink.cmp")
blink_cmp.download():pwait()

vim.lsp.enable({ "ols", "clangd", "pyright", "gh_actions_ls", "jsonls", "rust_analyzer", "gleam" })
for server, config in pairs(lsp_configs) do
  config.capabilities = blink_cmp.get_lsp_capabilities(config.capabilities)
  vim.lsp.config(server, config)
  vim.lsp.enable(server)
end

require("mini.icons").setup {}
blink_cmp.setup {
  fuzzy = { implementation = "prefer_rust_with_warning" },
  signature = { enabled = true },
  keymap = {
    preset = "super-tab",
    ['<C-k>'] = { 'show_documentation' },
    ['<C-u>'] = { 'scroll_documentation_up' },
    ['<C-d>'] = { 'scroll_documentation_down' },
  },
  completion = {
    -- preview of currently selected item as virtual text inline
    ghost_text = { enabled = true },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 400,
      window = { border = "single" },
    },
    list = { selection = { auto_insert = false } },
    accept = { auto_brackets = { enabled = true } },
    menu = {
      border = "single",
      draw = {
        -- align_to = "label",
        components = {
          label = {
            -- ensure text of completion item doesn't get cut off, as it
            -- does not seem to occupy the available width by default
            width = { fill = true, max = 80 },
          },
        --   kind_icon = {
        --     text = function(ctx)
        --       local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
        --       return kind_icon .. ctx.icon_gap
        --     end,
        --     highlight = function(ctx)
        --       local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
        --       return hl
        --     end,
        --   },
        --   kind = {
        --     highlight = function(ctx)
        --       local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
        --       return hl
        --     end,
        --   }
        }
      }
    }
  },
}
