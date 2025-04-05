local cmp = require("cmp")

local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_text(0, line-1, 0, line-1, col, {})[1]:match("^%s*$") == nil
end

cmp.setup({
  sources = {
    { name = 'nvim_lsp', keyword_length = 1 },
    { name = 'copilot' },
    { name = 'vsnip', keyword_length = 2 },
    { name = 'nvim_lsp_signature_help'},
    { name = 'nvim_lua', keyword_length = 2},
    { name = 'calc' },   
    { name = 'buffer', keyword_length = 2 },
    { name = 'path' },
  },
  mapping = {
    ["<Tab>"] = vim.schedule_wrap(function(fallback)
      if cmp.visible() and has_words_before() then
        cmp.confirm({ select = true })
      else
        fallback()
      end
    end),
  },
})

