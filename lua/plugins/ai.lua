return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = true },
        filetypes = {
          markdown = true,
          help = true,
          yaml = true,
          gitcommit = true,
        },
      })
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim", branch = "master" },
      "zbirenbaum/copilot.lua",
      "nvim-telescope/telescope.nvim",
    },
    build = "make tiktoken",
    opts = {
      model = "gpt-4o",
      auto_insert_mode = true,
      window = {
        layout = "float",
        border = "rounded",
      },
    },
  },
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("chatgpt").setup({
        api_key_cmd = "printf '%s' \"$OPENAI_API_KEY\"",
        openai_params = {
          model = "gpt-4o-mini",
        },
      })
    end,
  },
}
