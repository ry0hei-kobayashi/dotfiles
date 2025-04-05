
vim.keymap.set('t', '<ESC>', '<C-\\><C-n>', { silent = true })
vim.keymap.set('t', 'jj', '<C-\\><C-n>', { silent = true })
--vim.api.nvim_create_autocmd("VimEnter", {
--  callback = function()
--    -- すべてのバッファをチェックしてターミナルが存在するか確認
--    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
--      if vim.api.nvim_buf_get_option(buf, "buftype") == "terminal" then
--        return  -- すでにターミナルがある場合は終了
--      end
--    end
--
--    -- 現在のバッファが空ならターミナルを開く
--    if vim.fn.expand("%") == "" and GetBufByte() == 0 then
--      vim.cmd("terminal")
--    end
--  end,
--})
--
--function GetBufByte()
--  local byte = vim.fn.line2byte(vim.fn.line("$") + 1)
--  if byte == -1 then
--    return 0
--  else
--    return byte - 1
--  end
--end
