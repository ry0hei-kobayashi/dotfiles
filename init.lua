vim.loader.enable()

require('globals')

-- lazy.nvimの自動インストール
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins.lazy")

require('plugins.mini')  
--require('plugins.telescope')
require('plugins.lsp')
require('plugins.toggleterm')
require('plugins.nerdtree')
require('plugins.ui')
require('plugins.completion')
require('plugins.copilot')
require('plugins.markdown-preview')
require('plugins.fuzmotion')
