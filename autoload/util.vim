" Set ftplugin settings in easier way.
"
" This function helps avoid boilerplate code.
" Supports :setlocal command only.
" Sets `b:undo_ftplugin` automatically.
"
" Parameters:
"   options: dict of options to set locally for filetype
function! util#ftplugin_setlocal(options)
  for [option_name, option_value] in items(a:options)
    if type(option_value) == v:t_bool
      if !option_value
        execute "setlocal ".."no"..option_name
      else
        execute "setlocal "..option_name
      endif
    else
      execute "setlocal "..option_name.."="..option_value
    endif
  endfor
  if !exists("b:undo_ftplugin")
    let b:undo_ftplugin = ""
  endif
  let b:undo_ftplugin ..= "|setlocal "..join(map(keys(a:options), 'v:val.."<"'), " ")
endfunction
