setlocal nonumber norelativenumber

if !exists("b:undo_ftplugin")
  let b:undo_ftplugin = ""
endif
let b:undo_ftplugin ..= "|setlocal number< relativenumber<"
