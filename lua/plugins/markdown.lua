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
      -- Leave mkdp_browser unset on macOS: the plugin's opener.js detects
      -- darwin and calls `open <url>` itself. Setting it to "open" produces
      -- `open -a open <url>` (invalid). On Linux, mkdp uses xdg-open by
      -- default too — only override if you want a specific browser binary.
      vim.g.mkdp_echo_preview_url = 1
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", desc = "Markdown Preview" },
      { "<leader>ms", "<cmd>MarkdownPreviewStop<CR>", desc = "Stop Preview" },
    },
  },
}
