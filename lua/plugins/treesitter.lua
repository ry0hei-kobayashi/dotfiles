return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "bash",
          "c",
          "cpp",
          "cmake",
          "lua",
          "python",
          "vim",
          "vimdoc",
          "markdown",
          "markdown_inline",
          "json",
          "yaml",
          "regex",
          "query",
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
}
