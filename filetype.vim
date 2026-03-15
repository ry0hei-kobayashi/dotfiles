"au BufRead,BufNewFile *.def setfiletype def
augroup filetypedetect
  autocmd!
  autocmd BufRead,BufNewFile *.def setfiletype def
augroup END
