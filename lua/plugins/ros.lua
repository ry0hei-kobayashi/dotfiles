return {
  {
    "taDachs/ros-nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("ros-nvim").setup({
        only_workspace = true,
        telescope = {
          ws_filter = "current",
        },
        treesitter = {
          enabled = true,
        },
        commands = {
          enabled = true,
        },
        autocmds = {
          enabled = true,
        },
      })
    end,
  },
}
