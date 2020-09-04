" temporary for development {{{1
if exists("s:vim_home")
  unlet s:vim_home
endif
nnoremap <silent> ws :w<cr>:so %<cr>

" base Neovim directory {{{1
const s:vim_home = expand(fnamemodify($MYVIMRC, ":p:h"))

" vim:foldmethod=marker
