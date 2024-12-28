-- mini.completion 設定
require('mini.completion').setup({
  lsp_completion = {
    source_func = 'omnifunc',
    auto_setup = true,
  },
  delay = {
    completion = 100,
    info = 500,
    signature = 500,
  },
})


_G.tab_complete = function()
  -- 補完ウィンドウが表示されている場合は次の候補へ
  if vim.fn.pumvisible() == 1 then
    return vim.api.nvim_replace_termcodes('<C-n>', true, true, true)
  -- バックスペースが空白の場合はTabを入力
  elseif check_backspace() then
    return vim.api.nvim_replace_termcodes('<Tab>', true, true, true)
  -- それ以外の場合は補完をトリガー
  else
    return vim.api.nvim_replace_termcodes('<C-x><C-o>', true, true, true)
  end
end

_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return vim.api.nvim_replace_termcodes('<C-p>', true, true, true)
  else
    return vim.api.nvim_replace_termcodes('<S-Tab>', true, true, true)
  end
end

-- バックスペースが空白かどうかをチェック
function _G.check_backspace()
  local col = vim.fn.col('.') - 1
  return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s')
end

-- タブ補完のキー設定
vim.api.nvim_set_keymap('i', '<Tab>', 'v:lua.tab_complete()', { expr = true, noremap = true })
vim.api.nvim_set_keymap('i', '<S-Tab>', 'v:lua.s_tab_complete()', { expr = true, noremap = true })
