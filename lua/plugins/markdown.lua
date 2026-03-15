return {
  {
    "iamcco/markdown-preview.nvim",
    lazy = false,
    priority = 900,
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_auto_start = 1
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_open_to_the_world = 0
      --vim.g.mkdp_browser = "xdg-open"
      vim.g.mkdp_echo_preview_url = 1
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", desc = "Markdown Preview" },
      { "<leader>ms", "<cmd>MarkdownPreviewStop<CR>", desc = "Stop Preview" },
    },
  },
}
