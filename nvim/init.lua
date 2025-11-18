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
  pattern = { 'html', 'xhtml', 'js', 'jsx', 'ts', 'tsx', 'css', 'scss', 'lua', 'json', 'nix', 'py', 'dart', 'fish', 'sh' },
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

--------------------
--- Setup mini.deps
--------------------

-- Clone "mini.nvim" manually in a way that it gets managed by "mini.deps"
local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/start/mini.nvim"
--- @diagnostic disable-next-line: undefined-field
if not vim.loop.fs_stat(mini_path) then
  vim.cmd("echo 'Installing mini.nvim'")
  local clone_cmd = {
    "git", "clone", "--filter=blob:none",
    "https://github.com/nvim-mini/mini.nvim", mini_path
  }
  vim.fn.system(clone_cmd)
  vim.cmd.packadd("mini.nvim")
  vim.cmd.helptags("ALL")
  vim.cmd("echo 'Installed mini.nvim'")
end

require("mini.deps").setup {
  path = { package = path_package },
}

local add = MiniDeps.add

-- add({ source = "nvim-mini/mini.pairs", checkout = "stable" })
require("mini.pairs").setup {}
require("mini.icons").setup {}
MiniIcons.tweak_lsp_kind()
MiniIcons.mock_nvim_web_devicons()

add("lewis6991/gitsigns.nvim")

add({
  source = "dmtrKovalenko/fff.nvim",
  hooks = { post_install = function()
    require("fff.download").download_or_build_binary()
  end },
})

-- move from vertical to horizontal layout at >= x cols
local FLEX_BREAKPOINT_COLS = 170
require("fff").setup {
  layout = {
    preview_position = function(vpwidth, _)
      return vpwidth > FLEX_BREAKPOINT_COLS and "right" or "top"
    end,
  },
  keymaps = {
    move_up = { "<Up>", "<C-u>" },
  },
}

add({
  source = "nvim-telescope/telescope.nvim",
  checkout = "0.1.8",
  depends = { "nvim-lua/plenary.nvim" },
})
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
      flex = {
        flip_columns = FLEX_BREAKPOINT_COLS,
      },
    },
  },
}
add("norcalli/nvim-colorizer.lua")
require("colorizer").setup {
  "css", "javascript", "typescript", "javascriptreact", "typescriptreact",
}

--------------------
--- Colorscheme
--------------------

add("scottmckendry/cyberdream.nvim")
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
map("n", "<Leader>gc", telescope.current_buffer_fuzzy_find)

map("n", "<C-s>", function() telescope.buffers { layout_strategy = "center" } end)
map("n", "<Leader>b", function() telescope.buffers { layout_strategy = "center" } end)
map("n", "gs", telescope.lsp_document_symbols)
map("n", "gS", telescope.lsp_workspace_symbols)
map("n", "<Leader>gc", telescope.git_commits)
map("n", "<Leader>gd", telescope.git_status)

map("n", "<Esc>", "<cmd>noh<cr>")
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal node" })

--------------------
--- LSP
--------------------

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function()
    vim.diagnostic.config { virtual_lines = true }

    map("n", "gd", vim.lsp.buf.definition)
    map("n", "gD", vim.lsp.buf.declaration)
    map("n", "<C-;>", vim.lsp.buf.code_action)
  end,
})

add("https://github.com/nvim-treesitter/nvim-treesitter")
--- @diagnostic disable-next-line: missing-fields
require("nvim-treesitter.configs").setup {
  ensure_installed = {
    "odin", "lua", "javascript", "c", "cpp", "vimdoc", "java", "comment", "query", "jsdoc", "dart",
    "angular", "rust", "python", "javascript", "diff", "zig", "go", "bash", "xml", "typescript",
    "css", "fish", "make", "tsx", "graphql", "prisma", "terraform", "yaml",
  },
  highlight = { enable = true },
  indent = { enable = true },
}

add("mason-org/mason.nvim")
add("mason-org/mason-lspconfig.nvim")

-- NOTE: dartls and nixd are gone from the registry for some reason
local lsp_clients = { "pyright", "zls", "ts_ls", "bashls", "prismals", "jdtls" }
local is_nixos = vim.fn.isdirectory("/nix/store")
local home = os.getenv("HOME")
-- filter out problematic lsp servers, which usually package themselves as a .so; assume the wrapped version
-- is used instead on nixos
if is_nixos == 0 then
  table.insert(lsp_clients, { "lua_ls", "clangd" })
end

local lsp_configs = {
  nixd = {
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

-- lsp registries
require("mason").setup {}
require("mason-lspconfig").setup {
  ensure_installed = lsp_clients,
  automatic_installation = true,
}

-- lspconfig only used as config repo, actual configuration happens through vim.lsp
add("https://github.com/neovim/nvim-lspconfig")
add({
  source = "https://github.com/Saghen/blink.cmp",
  checkout = "v1.7.0",
})

vim.lsp.enable({ "ols", "clangd", "pyright", "gh_actions_ls" })
local blink_cmp = require("blink.cmp")
for server, config in pairs(lsp_configs) do
  config.capabilities = blink_cmp.get_lsp_capabilities(config.capabilities)
  vim.lsp.config(server, config)
  vim.lsp.enable(server)
end

require("mini.icons").setup {}
require("blink.cmp").setup {
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
