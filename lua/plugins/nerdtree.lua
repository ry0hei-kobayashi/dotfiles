return {
  {
    "preservim/nerdtree",
    cmd = { "NERDTree", "NERDTreeToggle", "NERDTreeFind" },
    keys = {
      { "<C-n>", "<cmd>NERDTreeToggle<CR>", desc = "NERDTree Toggle" },
    },
    init = function()
      vim.g.NERDTreeShowHidden = 1
      vim.g.NERDTreeMinimalUI = 1
      vim.g.NERDTreeDirArrows = 1
      vim.g.NERDTreeQuitOnOpen = 0
      vim.g.NERDTreeWinSize = 32
    end,
  },
  {
    "ryanoasis/vim-devicons",
    lazy = true,
  },
}
