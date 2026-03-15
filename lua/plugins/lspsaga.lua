return {
  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-tree/nvim-web-devicons",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("lspsaga").setup({
        ui = {
          border = "rounded",
          code_action = "🚕",
        },
        lightbulb = {
          enable = false,
        },
        symbol_in_winbar = {
          enable = false,
        },
      })

      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      map("n", "gd", "<cmd>Lspsaga peek_definition<CR>", opts)
      map("n", "gD", "<cmd>Lspsaga goto_definition<CR>", opts)
      map("n", "gt", "<cmd>Lspsaga peek_type_definition<CR>", opts)
      map("n", "gT", "<cmd>Lspsaga goto_type_definition<CR>", opts)
      map("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts)
      map("n", "gj", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts)
      map("n", "gk", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts)
      map("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts)

    end,
  },
}
