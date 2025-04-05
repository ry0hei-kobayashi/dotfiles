
return {
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
        {"<leader>mp", "<cmd>MarkdownPreview<CR>",  desc = "Preview Markdown" },
        {"<leader>ms", "<cmd>MarkdownPreviewStop<CR>",  desc = "Stop Preview" },
    },
  },
}

