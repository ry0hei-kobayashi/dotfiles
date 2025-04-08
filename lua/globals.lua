vim.loader.enable()

-- initialization
vim.g.loaded_gzip = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_netrwPlugin = 1
vim.g.mapleader = ' '

vim.opt.shortmess:append("I") -- 起動時メッセージ抑制
vim.opt.cmdheight = 1         -- コマンドラインの高さ（できれば1以上に）

-- setting
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.autoread = true
vim.opt.hidden = true
vim.opt.showcmd = true

vim.opt.clipboard = 'unnamedplus,unnamed'

-- 見た目
vim.opt.number = true
vim.opt.splitright = true
vim.opt.showmatch = true
vim.opt.laststatus = 2
vim.opt.signcolumn = 'yes'
vim.opt.wildmode = "list:longest"
vim.opt.background = "dark"

-- 折り返し時のカーソル移動
vim.opt.wrap = false
vim.api.nvim_set_keymap("n", "j", "gj", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "k", "gk", { noremap = true, silent = true })

-- シンタックスハイライト有効化
vim.cmd("syntax enable")

-- Tab関連の設定
vim.opt.tabstop = 4                    -- タブの幅
vim.opt.shiftwidth = 4                 -- インデント幅
vim.opt.expandtab = true               -- タブをスペースに変換
vim.opt.smartindent = true             -- スマートインデント
vim.cmd("retab 4")                     -- 既存のタブを4スペースに変換

-- 検索設定
vim.opt.ignorecase = true              -- 小文字で検索時は大文字小文字を区別しない
vim.opt.smartcase = true               -- 検索文字列に大文字が含まれている場合は区別
vim.opt.incsearch = true               -- 検索時に順次マッチ
vim.opt.wrapscan = true                -- 検索時に最初に戻る
vim.opt.hlsearch = true                -- 検索語をハイライト表示

-- ESC連打で検索ハイライトを解除
vim.api.nvim_set_keymap("n", "<Esc><Esc>", ":nohlsearch<CR><Esc>", { noremap = true, silent = true })

-- マウスの有効化 (tmuxスクロール問題対応)
vim.opt.mouse = "a"

-- Insertモードから抜けたら英字入力に切り替え (ibus使用時)
if vim.fn.executable("ibus") == 1 then
  vim.api.nvim_create_autocmd("InsertLeave", {
    command = ":silent !ibus engine xkb:us::eng"
  })
end
-- fcitx-remote (IME制御) を使いたい場合
if vim.fn.executable("fcitx-remote") == 1 then
  vim.api.nvim_create_autocmd("InsertLeave", {
    command = ":silent !fcitx-remote -c"
  })
end

vim.opt.completeopt = 'menu,menuone,noselect,popup' -- mini.completionで必要な設定


-- visual modeの色設定，カラースキーム設定後に再適用
-- vim.api.nvim_set_hl(0, "Visual", { fg = "#000000", bg = "#FFFF00", ctermfg = "black", ctermbg = "yellow" })
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "Visual", {
      fg = "#000000",
      bg = "#FFFF00",
      ctermfg = "black",
      ctermbg = "yellow"
    })
  end
})

-- for exception
vim.treesitter.start = (function(wrapped)
  return function(bufnr, lang)
    lang = lang or vim.fn.getbufvar(bufnr or '', '&filetype')
    pcall(wrapped, bufnr, lang)
  end
end)(vim.treesitter.start)
vim.opt.foldtext = [[v:lua.vim.treesitter.foldtext()]]


