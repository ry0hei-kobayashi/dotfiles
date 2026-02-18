-- mini.depsの初期設定
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'

if not vim.uv.fs_stat(mini_path) then
    vim.cmd('echo "Installing `mini.nvim`" | redraw')
    local clone_cmd = { 'git', 'clone', '--filter=blob:none', 'https://github.com/echasnovski/mini.nvim', mini_path }
    vim.fn.system(clone_cmd)
    vim.cmd('packadd mini.nvim | helptags ALL')
    vim.cmd('echo "Installed `mini.nvim`" | redraw')
end
require('mini.deps').setup { path = { package = path_package } }


local opts = { noremap = true, silent = true }
local bufopts = { buffer = true, noremap = true, silent = true }
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local on_attach = function(on_attach)
    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
            local buffer = args.buf
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            on_attach(client, buffer)
        end,
    })
end

now(function()
    require('mini.basics').setup {
        options = {
            extra_ui = true,
            win_borders = 'single',
        },
        mappings = {
            option_toggle_prefix = 'm',
        },
    }
end)

--Go forward/backward with square brackets
later(function()
    -- '[',']'起点のマッピングを追加
    require('mini.bracketed').setup()
end)


-- auto bracket <<<<<<<<<<<<<<<<<<<
require('mini.pairs').setup({
  -- 設定の適用モード
  modes = { insert = true, command = false, terminal = false },

  -- ペアのマッピング
  mappings = {
    -- 括弧類の自動補完
    ['('] = { action = 'open', pair = '()', neigh_pattern = '[^\\].' },
    ['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\].' },
    ['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\].' },

    [')'] = { action = 'close', pair = '()', neigh_pattern = '[^\\].' },
    [']'] = { action = 'close', pair = '[]', neigh_pattern = '[^\\].' },
    ['}'] = { action = 'close', pair = '{}', neigh_pattern = '[^\\].' },

    -- クォート類の自動補完
    ['"'] = { action = 'closeopen', pair = '""', neigh_pattern = '[^\\].', register = { cr = false } },
    ["'"] = { action = 'closeopen', pair = "''", neigh_pattern = '[^%a\\].', register = { cr = false } },
    ['`'] = { action = 'closeopen', pair = '``', neigh_pattern = '[^\\].', register = { cr = false } },
  },
})
later(function()
    -- 対となる括弧等を挿入してくれる
    require('mini.surround').setup()
end)
-- auto bracket >>>>>>>>>>>>>>>>>>>>

later(function()
    -- gcc等でコメントをトグルできる
    require('mini.comment').setup()
end)

now(function()
    -- 補完
    require('mini.completion').setup()
end)

later(function()
    -- 表示領域内のカーソル下と同単語に下線を付ける
    require('mini.cursorword').setup()
end)


later(function()
    -- gitsignsのように差分が表示される
    require('mini.diff').setup()
    MiniDiff.config.view.style = 'sign'
end)

later(function()
    -- mini.hogeに対して便利関数が追加される
    require('mini.extra').setup()
end)


now(function()
    -- ファイラー
    require('mini.files').setup { window = { preview = true } }
    vim.keymap.set('n', '<Leader>e', MiniFiles.open, opts)
    vim.keymap.set('n', '<Leader>E', function()
        MiniFiles.open(vim.api.nvim_buf_get_name(0))
    end, opts)
end)

now(function()
    -- ステータスライン
    require('mini.statusline').setup()
end)


later(function()
    -- タブライン
    require('mini.tabline').setup()
end)


later(function()
    -- git関連のコマンド等を追加してくれる（全然使いこなせてない）
    require('mini.git').setup()
end)

later(function()
    -- nvim_web_deviconsの代わり
    require('mini.icons').setup()
    MiniIcons.mock_nvim_web_devicons()
end)

later(function()
    -- 縦移動が見やすくなる
    require('mini.indentscope').setup()
end)

later(function()
    -- 通知
    require('mini.notify').setup()
end)

later(function()
    -- telescope的なやつ
    require('mini.pick').setup()
    vim.keymap.set('n', [[\e]], '<Cmd>Pick explorer<Cr>', opts)
    vim.keymap.set('n', [[\b]], '<Cmd>Pick buffers<Cr>', opts)
    vim.keymap.set('n', [[\h]], '<Cmd>Pick help<Cr>', opts)
    vim.keymap.set('n', [[\\]], '<Cmd>Pick grep<Cr>', opts)
    vim.keymap.set('n', [[\f]], '<Cmd>Pick files<Cr>', opts)
    vim.keymap.set('n', [[\g]], '<Cmd>Pick git_files<Cr>', opts)
    vim.keymap.set('n', [[\l]], '<Cmd>Pick buf_lines<Cr>', opts)
    vim.keymap.set('n', [[\m]], '<Cmd>Pick visit_paths<Cr>', opts)
end)

later(function()
    -- gSでJの逆操作してくれるやつ
    require('mini.splitjoin').setup()
end)

now(function()
    require('mini.starter').setup()
end)

now(function()
    -- mr.vimのように訪問したファイルを記録してくれるやつ
    require('mini.visits').setup()
end)

later(function()
    add('https://github.com/kdheepak/lazygit.nvim')
    vim.keymap.set('n', '<Leader><Leader>', '<Cmd>LazyGit<Cr>', opts)
end)

now(function()
  add('https://github.com/nvim-treesitter/nvim-treesitter')
end)

later(function()
  require('nvim-treesitter.configs').setup {
    ensure_installed = {
      'astro',
      'css',
      'go',
      'gomod',
      'gosum',
      'html',
      'lua',
      'markdown',
      'markdown_inline',
      'rust',
      'toml',
      'typescript',
    },
    highlight = {
      enable = true,
      disable = function(lang, buf)
                -- filetypeやファイルサイズによってtreesitterを無効化させる
        if lang == 'vimdoc' then
          return true
        end
        local max_filesize = 50 * 1024 -- 50 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          vim.print('File too large: tree-sitter disabled.', 'WarningMsg')
          return true
        end
        if vim.fn.line('$') > 20000 then
          vim.print('Buffer has too many lines: tree-sitter disabled.', 'WarningMsg')
          return true
        end
      end,
      additional_vim_regex_highlighting = false,
    },
    sync_install = false,
    modules = {},
    auto_install = true,
    ignore_install = {},
  }
end)


later(function()
    add {
        source = 'https://github.com/nvimdev/lspsaga.nvim',
        depends = { 'nvim-lspconfig' },
    }

    require('lspsaga').setup {
        ui = {
            code_action = '🚕',
        },
        lightbulb = {
            enable = false,
        },
        symbol_in_winbar = {
            enable = false,
        },
        code_action = {
            show_server_name = true,
            extend_gitsigns = true,
        },
    }

    ---@param action string
    ---@return string
    local doSagaAction = function(action)
        return string.format('<Cmd>Lspsaga %s<Cr>', action)
    end

    -- LS関連のマッピングを設定
    on_attach(function(_)
        vim.keymap.set('n', 'gr', doSagaAction('rename'), bufopts)
        vim.keymap.set('n', 'gd', doSagaAction('peek_definition'), bufopts)
        vim.keymap.set('n', 'gD', doSagaAction('goto_definition'), bufopts)
        vim.keymap.set('n', 'gt', doSagaAction('peek_type_definition'), bufopts)
        vim.keymap.set('n', 'gT', doSagaAction('goto_type_definition'), bufopts)
        vim.keymap.set('n', 'g<Space>', doSagaAction('code_action'), bufopts)
        vim.keymap.set('n', 'gl', doSagaAction('show_line_diagnostics'), bufopts)
        vim.keymap.set('n', 'gj', doSagaAction('diagnostics_jump_next'), bufopts)
        vim.keymap.set('n', 'gk', doSagaAction('diagnostics_jump_prev'), bufopts)
        vim.keymap.set('n', 'K', doSagaAction('hover_doc'), bufopts)
    end)

end)


--now(function()
--    -- カラースキームを作るやつ
--    require('mini.base16').setup {
--        palette = {
--            base00= "#EFECF4",
--            base01= "#E2DFE7",
--            base02= "#8B8792",
--            base03= "#7E7887",
--            base04= "#655F6D",
--            base05= "#585260",
--            base06= "#26232A",
--            base07= "#19171C",
--            base08= "#BE4678",
--            base09= "#AA573C",
--            base0A= "#A06E3B",
--            base0B= "#2A9292",
--            base0C= "#398BC6",
--            base0D= "#576DDB",
--            base0E= "#955AE7",
--            base0F= "#BF40BF",
--        },
--    }
--end)
