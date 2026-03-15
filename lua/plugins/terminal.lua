return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      size = 15,
      open_mapping = [[<c-t>]],
      start_in_insert = true,
      direction = "horizontal",
      shade_terminals = true,
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)

      vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { silent = true })
    end,
  },
}
