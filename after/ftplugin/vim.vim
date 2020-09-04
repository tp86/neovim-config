" always use spaces instead of tabs
setlocal expandtab
" use 2 spaces for tab
setlocal tabstop=2 softtabstop=2 shiftwidth=2
setlocal shiftround

if !exists("b:undo_ftplugin")
  let b:undo_ftplugin = ""
endif
let b:undo_ftplugin ..= "|setlocal expandtab< tabstop< softtabstop< shiftwidth< shiftround<"
