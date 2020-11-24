function! statusline#active()
  return luaeval("require'config/statusline'.active()")
endfunction
