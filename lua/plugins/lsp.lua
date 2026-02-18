-- ~/.config/nvim/lua/plugins/lsp.lua

-- Mason (installer)
require('mason').setup()

require('mason-lspconfig').setup {
  ensure_installed = { 'lua_ls', 'gopls', 'denols', 'bashls', 'pyright' },
}

local util = require('lspconfig').util
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- =========================
-- LSP server configs (nvim 0.11 style)
-- =========================

-- Lua
vim.lsp.config("lua_ls", {
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' },
      },
    },
  },
})

-- Go
vim.lsp.config("gopls", {
  capabilities = capabilities,
  cmd = { 'gopls' },
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
    },
  },
})

-- Deno
vim.lsp.config("denols", {
  capabilities = capabilities,
  root_dir = util.root_pattern("deno.json", "deno.jsonc"),
  init_options = {
    lint = true,
  },
})

-- Bash
vim.lsp.config("bashls", {
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh", "bash", "zsh", "def" },
  root_dir = util.find_git_ancestor,
})

-- Pyright
vim.lsp.config("pyright", {
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",      -- "off" | "basic" | "strict"
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly" -- 重ければ openFilesOnly、全体なら "workspace"
      },
    },
  },
})

-- Enable servers
vim.lsp.enable({ "lua_ls", "gopls", "denols", "bashls", "pyright" })

-- =========================
-- Diagnostics UI
-- =========================
for type, icon in pairs { Error = 'E', Warn = 'W', Hint = 'H', Info = 'I' } do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focusable = false })
  end,
})

-- =========================
-- Keymaps on attach
-- =========================
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local bufopts = { noremap = true, silent = true, buffer = bufnr }

    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', 'K',  vim.lsp.buf.hover, bufopts)
  end
})

