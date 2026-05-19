-- Pick a tokyonight variant based on the host OS.
--   macOS: follow the system Appearance (Dark / Light), and override the
--          syntax palette to be more vivid since Terminal.app's 256-color
--          rendering otherwise washes out the default pastel tones.
--   Linux / other: stay with the stock dark variant.
local function macos_is_dark()
  local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
  if not handle then
    return false
  end
  local out = handle:read("*a") or ""
  handle:close()
  return out:match("Dark") ~= nil
end

local sysname = vim.loop.os_uname().sysname
local is_macos = sysname == "Darwin"

local function pick_theme()
  if is_macos then
    return macos_is_dark() and "tokyonight-night" or "tokyonight-day"
  end
  return "tokyonight-night"
end

local theme = pick_theme()

return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        on_colors = is_macos and function(colors)
          colors.fg       = "#ffffff"
          colors.fg_dark  = "#f0f0f0"
          colors.fg_float = "#ffffff"

          -- Vivid syntax palette (Dracula / Palenight-inspired)
          colors.red     = "#ff5d5d"
          colors.red1    = "#ff5d5d"
          colors.orange  = "#ffa657"
          colors.yellow  = "#ffd866"
          colors.green   = "#7ce38b"
          colors.green1  = "#5ee686"
          colors.green2  = "#5ee686"
          colors.teal    = "#5cdfd6"
          colors.cyan    = "#5cdfff"
          colors.blue    = "#82aaff"
          colors.blue0   = "#5599ff"
          colors.blue1   = "#82aaff"
          colors.blue2   = "#82aaff"
          colors.magenta = "#d49bff"
          colors.purple  = "#bd93f9"
        end or nil,
        on_highlights = is_macos and function(hl, c)
          local panel_bg = "#3b4252"
          hl.Normal       = { fg = "#ffffff" }
          hl.NormalFloat  = { fg = "#ffffff", bg = panel_bg }
          hl.FloatBorder  = { fg = "#82aaff", bg = panel_bg }
          hl.Pmenu        = { fg = "#ffffff", bg = panel_bg }
          hl.PmenuSel     = { fg = "#000000", bg = "#5cdfff" }
          hl.PmenuSbar    = { bg = panel_bg }
          hl.PmenuThumb   = { bg = "#82aaff" }
          hl.Comment      = { fg = "#a0a8c0", italic = true }
        end or nil,
      })
      vim.cmd.colorscheme(theme)
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "tokyonight",
          globalstatus = true,
        },
      })
    end,
  },
}
