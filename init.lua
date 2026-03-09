-- =========================================
-- init.lua - Neovim (Conda)
-- Pyright + Ruff + Treesitter
-- Plugin manager: packer.nvim
-- =========================================

-- Leader Key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- =========================================
-- Basic Settings
-- =========================================
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Faster update time for cursor hold (triggers the error pop-up faster)
vim.opt.updatetime = 250 

-- Conda-aware Python host
local conda_prefix = os.getenv("CONDA_PREFIX")
if conda_prefix then
  vim.g.python3_host_prog = conda_prefix .. "/bin/python"
end

-- =========================================
-- Packer bootstrap
-- =========================================
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
    vim.cmd("packadd packer.nvim")
    return true
  end
  return false
end
local packer_bootstrap = ensure_packer()

-- =========================================
-- Plugins
-- =========================================
require("packer").startup(function(use)
  use "wbthomason/packer.nvim"
  
  -- LSP & Mason
  use "williamboman/mason.nvim"
  use "williamboman/mason-lspconfig.nvim"
  use "neovim/nvim-lspconfig" -- The missing piece!
  
  -- Autocompletion
  use "hrsh7th/nvim-cmp"
  use "hrsh7th/cmp-nvim-lsp"
  
  -- Syntax Highlighting
  use { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }
  
  -- UI & Theme
  use { "catppuccin/nvim", as = "catppuccin" }
  use {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  }

  if packer_bootstrap then require("packer").sync() end
end)

if packer_bootstrap then return end

-- =========================================
-- Catppuccin Theme
-- =========================================
require("catppuccin").setup({ 
  flavour = "mocha", 
  integrations = { 
    treesitter = true, 
    native_lsp = { enabled = true } 
  } 
})
vim.cmd("colorscheme catppuccin")

-- =========================================
-- Treesitter
-- =========================================
local ok_ts, ts_configs = pcall(require, "nvim-treesitter.configs")
if ok_ts then
  ts_configs.setup({
    ensure_installed = { "python", "lua", "vim", "vimdoc" },
    highlight = { enable = true, additional_vim_regex_highlighting = false },
    indent = { enable = true },
  })
end

-- =========================================
-- Mason Setup
-- =========================================
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "pyright", "ruff" },
  automatic_installation = true,
})

-- =========================================
-- LSP Configuration (nvim-lspconfig)
-- =========================================
local capabilities = vim.lsp.protocol.make_client_capabilities()
pcall(function()
  capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
end)

local lspconfig = require("lspconfig")

-- 1. Setup Pyright (Type Checking)
lspconfig.pyright.setup({
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
})

-- 2. Setup Ruff (Linting & Formatting)
lspconfig.ruff.setup({
  capabilities = capabilities,
})

-- =========================================
-- Diagnostics (Icons & Pop-ups)
-- =========================================
-- Set custom icons in the sign column
local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- Auto-show diagnostic popup on cursor hold
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    local opts = {
      focusable = false,
      close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
      border = 'rounded',
      source = 'always',
      prefix = ' ',
      scope = 'cursor',
    }
    vim.diagnostic.open_float(nil, opts)
  end
})

-- =========================================
-- Completion (nvim-cmp)
-- =========================================
local cmp = require("cmp")
cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = { { name = "nvim_lsp" } },
})

-- =========================================
-- Format on Save
-- =========================================
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.py",
  callback = function()
    vim.lsp.buf.format({
      async = false,
      filter = function(client) return client.name == "ruff" end,
    })
  end,
})

-- =========================================
-- Keymaps
-- =========================================
vim.keymap.set("n", "<leader>w", ":w<CR>", { silent = true })
vim.keymap.set("n", "<leader>d", "yyp", { silent = true })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { silent = true })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { silent = true })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { silent = true })

-- Duplicate and comment helper
vim.keymap.set("n", "<leader>D", function()
  local line = vim.api.nvim_get_current_line()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, row, row, false, { line })
  vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
  require("Comment.api").toggle.linewise.current()
end))