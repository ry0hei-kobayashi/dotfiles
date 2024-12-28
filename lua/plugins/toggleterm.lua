require("toggleterm").setup({
  open_mapping = [[<c-t>]],
  hide_numbers = true,
  shade_filetypes = {},
  shade_terminals = true,
  shading_factor = 1,
  start_in_insert = true,
  persist_size = true,
  direction = "horizontal",
  close_on_exit = true,
  shell = vim.o.shell,
})

vim.api.nvim_set_keymap('t', '<C-[>', [[<C-\><C-n>]], { noremap = true, silent = true })

