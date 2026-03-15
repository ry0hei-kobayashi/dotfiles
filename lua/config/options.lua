local opt = vim.opt
local g = vim.g

-- =========================================================
-- initialization
-- =========================================================

g.loaded_gzip = 1
g.loaded_tar = 1
g.loaded_tarPlugin = 1
g.loaded_zip = 1
g.loaded_zipPlugin = 1
g.loaded_getscript = 1
g.loaded_getscriptPlugin = 1
g.loaded_vimball = 1
g.loaded_vimballPlugin = 1
g.loaded_matchit = 1
g.loaded_matchparen = 1
g.loaded_2html_plugin = 1
g.loaded_logiPat = 1
g.loaded_rrhelper = 1
g.loaded_netrwPlugin = 1

g.mapleader = " "

-- =========================================================
-- basic
-- =========================================================
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.mouse = "a"
opt.termguicolors = true
opt.shortmess:append("I")
opt.cmdheight = 1

opt.backup = false
opt.swapfile = false
opt.autoread = true
opt.hidden = true
opt.undofile = true
opt.undolevels = 10000
opt.undoreload = 10000

local undodir = vim.fn.stdpath("state") .. "/undo"
if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, "p")
end
opt.undodir = undodir

-- clipboard
opt.clipboard = "unnamedplus,unnamed"

-- =========================================================
-- ui
-- =========================================================
opt.number = true
opt.relativenumber = false
opt.signcolumn = "yes"
opt.laststatus = 2
opt.showcmd = true
opt.showmatch = true
opt.background = "dark"
opt.wildmode = "list:longest"

opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8

opt.splitright = true
opt.splitbelow = true

opt.updatetime = 200
opt.timeoutlen = 400

-- syntax
vim.cmd("syntax enable")

-- =========================================================
-- indent
-- =========================================================
opt.expandtab = true
opt.smartindent = true

-- 基本は4に統一
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4

-- =========================================================
-- search
-- =========================================================
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.inccommand = "split"
opt.wrapscan = true
opt.grepprg = "rg --vimgrep --smart-case --hidden"
opt.grepformat = "%f:%l:%c:%m"

-- =========================================================
-- completion
-- =========================================================
opt.completeopt = { "menu", "menuone", "noselect", "popup" }

-- =========================================================
-- keymaps related to options
-- =========================================================
vim.keymap.set("n", "j", "gj", { noremap = true, silent = true })
vim.keymap.set("n", "k", "gk", { noremap = true, silent = true })

vim.keymap.set("n", "<Esc><Esc>", "<cmd>nohlsearch<CR><Esc>", {
    noremap = true,
    silent = true,
})

-- =========================================================
-- IME off on InsertLeave
-- =========================================================
if vim.fn.executable("ibus") == 1 then
    vim.api.nvim_create_autocmd("InsertLeave", {
        callback = function()
            vim.fn.jobstart({ "ibus", "engine", "xkb:us::eng" }, { detach = true })
        end,
    })
end

if vim.fn.executable("fcitx-remote") == 1 then
    vim.api.nvim_create_autocmd("InsertLeave", {
        callback = function()
            vim.fn.jobstart({ "fcitx-remote", "-c" }, { detach = true })
        end,
    })
end

-- =========================================================
-- highlight
-- =========================================================
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
        vim.api.nvim_set_hl(0, "Visual", {
            fg = "#000000",
            bg = "#FFFF00",
            ctermfg = "black",
            ctermbg = "yellow",
        })
    end,
})

-- 起動直後にも反映
vim.api.nvim_set_hl(0, "Visual", {
    fg = "#000000",
    bg = "#FFFF00",
    ctermfg = "black",
    ctermbg = "yellow",
})
