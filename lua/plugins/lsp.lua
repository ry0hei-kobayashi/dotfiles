require('mason').setup()
local lspconfig = require('lspconfig')
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- mason-lspconfigのセットアップ
require('mason-lspconfig').setup {
  ensure_installed = { 'lua_ls', 'gopls', 'denols' },
}

-- 各LSPサーバごとにハンドラを設定
require('mason-lspconfig').setup_handlers {
  -- デフォルトの設定 (すべてのLSPに適用)
  function(server_name)
    if lspconfig[server_name] then
      lspconfig[server_name].setup {
        capabilities = capabilities,
      }
    end
  end,
  
  -- Lua
  ['lua_ls'] = function()
    lspconfig.lua_ls.setup {
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = {
            globals = { 'vim' },  -- vimグローバル変数を診断から除外
          },
        },
      },
    }
  end,

  -- Go
  ['gopls'] = function()
    lspconfig.gopls.setup {
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
    }
  end,

  -- Deno(json)
  ['denols'] = function()
    lspconfig.denols.setup {
      capabilities = capabilities,
      root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
      init_options = {
        lint = true,
      },
    }
  end,
}

require'lspconfig'.bashls.setup{
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh", "bash", "zsh", "def" },
  root_dir = require'lspconfig'.util.find_git_ancestor,
}

-- LSP診断メッセージのアイコン設定
--for type, icon in pairs { Error = '🚒', Warn = '🚧', Hint = '🦒', Info = '👀' } do
--  local hl = 'DiagnosticSign' .. type
--  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
--end
for type, icon in pairs { Error = 'E', Warn = 'W', Hint = 'H', Info = 'I' } do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focusable = false })
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local bufopts = { noremap=true, silent=true, buffer=bufnr }

    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', 'K',  vim.lsp.buf.hover, bufopts)
  end
})
