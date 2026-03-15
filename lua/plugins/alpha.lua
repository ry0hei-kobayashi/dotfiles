return {
  {
    "goolord/alpha-nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        [[███╗   ██╗██╗   ██╗██╗███╗   ███╗]],
        [[████╗  ██║██║   ██║██║████╗ ████║]],
        [[██╔██╗ ██║██║   ██║██║██╔████╔██║]],
        [[██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║]],
        [[██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║]],
        [[╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝]],
      }

      dashboard.section.buttons.val = {
        dashboard.button("e", "  New file", "<cmd>ene<CR>"),
        dashboard.button("f", "  Find file", "<cmd>Telescope find_files<CR>"),
        dashboard.button("r", "  Recent files", "<cmd>Telescope oldfiles<CR>"),
        dashboard.button("n", "  NERDTree", "<cmd>NERDTreeToggle<CR>"),
        --dashboard.button("m", "  Markdown Preview", "<cmd>MarkdownPreviewToggle<CR>"),
        dashboard.button("l", "󰒲  Lazy", "<cmd>Lazy<CR>"),
        dashboard.button("q", "  Quit", "<cmd>qa<CR>"),
      }

      dashboard.section.footer.val = {
        "",
        "Hello, ry0hei-kobayashi! Welcome to Neovim.",
      }

      dashboard.opts.opts.noautocmd = true
      alpha.setup(dashboard.opts)

      vim.keymap.set("n", "<leader>a", "<cmd>Alpha<CR>", { desc = "Alpha dashboard" })
    end,
  },
}
