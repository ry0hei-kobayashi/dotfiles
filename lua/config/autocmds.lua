local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local user_group = augroup("user_config", { clear = true })

autocmd("TextYankPost", {
  group = user_group,
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

-- Python uses 4 spaces
autocmd("FileType", {
  group = user_group,
  pattern = { "python" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
  end,
})

-- Common ROS/C++/Lua files use 2 spaces
autocmd("FileType", {
  group = user_group,
  pattern = { "cpp", "c", "cmake", "lua", "yaml", "json", "markdown", "xml" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end,
})

-- ROS-related file associations
autocmd({ "BufRead", "BufNewFile" }, {
  group = user_group,
  pattern = { "*.launch", "*.launch.xml", "*.xacro", "package.xml", "plugin.xml" },
  callback = function()
    vim.bo.filetype = "xml"
  end,
})

autocmd({ "BufRead", "BufNewFile" }, {
  group = user_group,
  pattern = { "*.msg", "*.srv", "*.action" },
  callback = function()
    vim.bo.filetype = "ros"
    vim.bo.commentstring = "# %s"
  end,
})

autocmd("TermOpen", {
  group = user_group,
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.cmd("startinsert")
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      vim.cmd("Alpha")
    end
  end,
})

--vim.api.nvim_create_autocmd("VimEnter", {
--  callback = function()
--    local argc = vim.fn.argc()
--    if argc == 0 then
--      vim.cmd("NERDTree")
--      return
--    end
--
--    local arg0 = vim.fn.argv(0)
--    if arg0 ~= "" and vim.fn.isdirectory(arg0) == 1 then
--      vim.cmd("NERDTree " .. arg0)
--    end
--  end,
--})
--
--
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, {
      focus = false,
      scope = "cursor",
      border = "rounded",
      source = "if_many",
      close_events = {
        "BufLeave",
        "CursorMoved",
        "InsertEnter",
        "FocusLost",
      },
    })
  end,
})
