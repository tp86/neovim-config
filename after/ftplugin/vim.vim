"setlocal expandtab
"setlocal tabstop=2 softtabstop=2 shiftwidth=2
"setlocal shiftround

"if !exists("b:undo_ftplugin")
  "let b:undo_ftplugin = ""
"endif
"let b:undo_ftplugin ..= "|setlocal expandtab< tabstop< softtabstop< shiftwidth< shiftround<"
let s:indent_size = 2
call util#ftplugin_setlocal({
      \ "expandtab": v:true,
      \ "tabstop": s:indent_size,
      \ "softtabstop": s:indent_size,
      \ "shiftwidth": s:indent_size,
      \ "shiftround": v:true,
      \})
