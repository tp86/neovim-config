" settings specific for Neovim-Qt {{{1
if exists("g:GuiLoaded")
  call GuiClipboard()
  GuiTabline 0
  GuiPopupmenu 0
  " archlinux: pacman -S ttf-hack
  GuiFont! Hack:h12
  call GuiWindowMaximized(v:true)
endif " }}}
" guicursor support in Neovim-Qt since v0.2.16
" blink in insert mode
set guicursor=n-v-c-sm:block-Cursor
set guicursor+=i-ci-ve:ver25-blinkwait200-blinkon500-blinkoff500
set guicursor+=r-cr-o:hor20

" always use system clipboard when yanking, deleting, etc.
set clipboard+=unnamed

" easy pasting in insert mode {{{1
function! s:insert_put()
  let keys = "\<esc>g"
  if col(".") == 1
    let keys ..= "P"
  else
    let keys ..= "p"
  endif
  if col(".") == col("$")
    let keys ..= "a"
  else
    let keys ..= "i"
  endif
  return keys
endfunction
inoremap <expr> <c-v> <sid>insert_put()
" restore option to insert verbose character
inoremap <c-g><c-v> <c-v>

" vim:foldmethod=marker
