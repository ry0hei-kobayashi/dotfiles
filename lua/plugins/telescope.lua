return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local builtin = require("telescope.builtin")

      telescope.setup({
        defaults = {
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = { preview_width = 0.58 },
          },
          mappings = {
            i = {
              ["<Esc>"] = actions.close,
            },
          },
          file_ignore_patterns = {
            "build/",
            "install/",
            "log/",
            ".git/",
          },
        },
        pickers = {
          find_files = {
            hidden = true,
          },
          live_grep = {
            additional_args = function()
              return { "--hidden" }
            end,
          },
        },
      })

      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })

      vim.keymap.set("n", "gD", builtin.lsp_definitions, { desc = "LSP definitions picker" })
      vim.keymap.set("n", "gI", builtin.lsp_implementations, { desc = "LSP implementations picker" })
      vim.keymap.set("n", "gR", builtin.lsp_references, { desc = "LSP references picker" })
      vim.keymap.set("n", "gT", builtin.lsp_type_definitions, { desc = "LSP type definitions picker" })
    end,
  },
}
