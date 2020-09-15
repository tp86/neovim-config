function! stl#filename()
  let bufname = bufname()
  let filename = fnamemodify(bufname, ":t")
  " special cases
  " filetype-based
  if index(["help"], &filetype) >= 0
    return filename
  endif
  if index(["nerdtree"], &filetype) >= 0
    return ""
  endif
  const full_bufname = fnamemodify(bufname, ":p")
  " git-diff buffers
  const git_type_to_name = {
        \ "0": "index",
        \ "2": "current",
        \ "3": "incoming",
        \}
  if full_bufname =~# '\v^fugitive:' .. escape(expand("/"), '\') .. '{2,}'
    let git_buf_type = matchstr(full_bufname, '\v' .. escape('.git' .. expand("/"), '.\') .. '{2}\zs\x+\ze')
    if !empty(git_buf_type)
      let git_type_name = get(git_type_to_name, git_buf_type, "(" .. git_buf_type[:7] .. ")")
      return filename .. " @ " .. git_type_name
    endif
  endif
  " terminal buffers
  if full_bufname =~# '\v^term://'
    let splitted_term_uri = split(full_bufname, ":")
    let shell_pid = fnamemodify(splitted_term_uri[1], ":t")
    let shell_exec = fnamemodify(splitted_term_uri[-1], ":t")
    return join([splitted_term_uri[0], shell_pid, shell_exec], ":")
  endif
  " buffer without file
  if empty(filename)
    return "[No Name]"
  endif
  " basic case
  function! s:relative_path(path, base_path)
    let full_base_path = escape(fnamemodify(a:base_path, ":p"), '\')
    let relative_path = matchstr(a:path, '\v' .. full_base_path .. '\zs.*$')
    if empty(relative_path)
      return a:path
    else
      return relative_path
    endif
  endfunction
  let relative_dir = fnamemodify(s:relative_path(full_bufname, getcwd()), ":h")
  if relative_dir ==# "."
    return filename
  else
    return expand(join([pathshorten(relative_dir), filename], "/"))
  endif
endfunction
function! stl#lsp()
  " TODO
  return 2
endfunction
