function! tbl#tabline_modified(tabpagenr)
  for winnr in range(1, tabpagewinnr(a:tabpagenr, "$"))
    if gettabwinvar(a:tabpagenr, winnr, "&modified")
      return "+"
    endif
  endfor
  return ""
endfunction

function! tbl#tabline_filename(tabpagenr)
  let winnr = tabpagewinnr(a:tabpagenr)
  let bufnr = tabpagebuflist(a:tabpagenr)[winnr - 1]
  let bufname = bufname(bufnr)
  let filename = fnamemodify(bufname, ":t")
  let full_bufname = fnamemodify(bufname, ":p")
  " special cases
  " terminal buffers
  if full_bufname =~# '\v^term://'
    let splitted_term_uri = split(full_bufname, ":")
    let shell_pid = fnamemodify(splitted_term_uri[1], ":t")
    let shell_exec = fnamemodify(splitted_term_uri[-1], ":t")
    return join([splitted_term_uri[0], shell_pid, shell_exec], ":")
  endif
  if empty(filename)
    return "[No Name]"
  endif
  " basic case
  return filename
endfunction
