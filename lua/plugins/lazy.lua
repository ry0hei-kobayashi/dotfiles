return {


  -- NERDTree (ファイラ)
  { "preservim/nerdtree", cmd = "NERDTreeToggle" },

  -- ToggleTerm (ターミナル)
  { "akinsho/toggleterm.nvim", version = "*", config = function()
    require("toggleterm").setup()
  end },

  -- GitSigns (Git変更表示)
  { "lewis6991/gitsigns.nvim", config = function()
    require("gitsigns").setup()
  end },


  -- テーマ (nightfox)
  { "EdenEast/nightfox.nvim", config = function()
    vim.cmd("colorscheme carbonfox")
  end },

  -- Startify (起動時の画面)
  --{ "mhinz/vim-startify" },

  -- インデント可視化
  { "lukas-reineke/indent-blankline.nvim", config = function()
    require("ibl").setup {
      indent = { char = "|" }
    }
  end },

  -- 括弧のレインボー表示
  { "HiPhish/rainbow-delimiters.nvim" },

  -- Telescope (ファジーファインダー)
  --{ "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" }, cmd = "Telescope" },

  -- Denops (Denoプラグイン)
  { "vim-denops/denops.vim" },

  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",  -- Masonのアップデートを自動実行
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "clangd", "dockerls", "bashls", "lua_ls", "pyright", "ts_ls" },  -- 必要なLSPを自動でインストール
        automatic_installation = true,
      })
    end,
  },

{ "neovim/nvim-lspconfig" },

--  {
--    "neovim/nvim-lspconfig",
--    config = function()
--      local lspconfig = require("lspconfig")
--      lspconfig.lua_ls.setup({})
--      lspconfig.pyright.setup({})
--      lspconfig.ts_ls.setup({})
--    end,
--  },

  -- mini.nvim (軽量プラグイン群)
  { "echasnovski/mini.nvim", config = function()
    require("mini.comment").setup()
    require("mini.cursorword").setup()
    require("mini.statusline").setup()
    require("mini.surround").setup()
  end },

  {
   "iamcco/markdown-preview.nvim",
   ft = { "markdown" },
   build = "cd app && npm install",
   init = function()
     vim.g.mkdp_auto_start = 1
     vim.g.mkdp_auto_close = 1
     vim.g.mkdp_open_to_the_world = 0
   end,
   keys = {
     { "<leader>mp", "<cmd>MarkdownPreview<CR>",     desc = "Preview Markdown" },
     { "<leader>ms", "<cmd>MarkdownPreviewStop<CR>", desc = "Stop Preview" },
   },

   {
    "hrsh7th/nvim-cmp",
   },

  {
   "github/copilot.vim", lazy=false
  },

  {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  config = function()
    require("copilot").setup({
      suggestion = {enabled = false},
      panel = {enabled = false},
      copilot_node_command = 'node'
    })
  end,
  },

  {
  "zbirenbaum/copilot-cmp",
  config = function ()
    require("copilot_cmp").setup()
  end
  },

  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      debug = true, -- Enable debugging
      -- See Configuration section for rest
    },
    -- See Commands section for default commands if you want to lazy load on them
  },

  {
    "ysmb-wtsg/in-and-out.nvim",
    keys = {
      {
      "<C-CR>",
        function()
        require("in-and-out").in_and_out()
        end,
        mode = "i"
      },
    opts = { additional_targets = {'"', "'", "(", ")", "{", "}", "[", "]", "`"} },
    },
  },

  {
    "cohama/lexima.vim",
    event = "InsertEnter",
  },

  {
    "JoosepAlviste/nvim-ts-context-commentstring"
  },

  {
    "yuki-yano/fuzzy-motion.vim",
    dependencies = { "lambdalisue/vim-kensaku" },
    cmd = { "FuzzyMotion" },
  },
  {
    "lambdalisue/vim-kensaku-search",
    dependencies = { "lambdalisue/vim-kensaku" },
    event = "VeryLazy",
  },
  {
    "lambdalisue/vim-kensaku",
    event = "VeryLazy",
  },
  {
    "haya14busa/vim-edgemotion",
    event = "VeryLazy",
  },


    {
      "jackMort/ChatGPT.nvim",
        event = "VeryLazy",
        config = function()
          require("chatgpt").setup()
        end,
        dependencies = {
          "MunifTanjim/nui.nvim",
          "nvim-lua/plenary.nvim",
          "folke/trouble.nvim",
          "nvim-telescope/telescope.nvim"
        }
    }



 },

}


