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
    let full_base_path = escape(fnamemodify(a:base_path, ":p"), '\%')
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
function! stl#lsp() abort
  if luaeval('#vim.lsp.buf_get_clients() > 0')
    let diagnostics = luaeval("require('lsp-status').diagnostics()")
    let errors = get(diagnostics, "errors", 0)
    let warnings = get(diagnostics, "warnings", 0)
    let info = get(diagnostics, "info", 0)
    let hints = get(diagnostics, "hints", 0)
    let diagnostics_count = errors + warnings + info + hints
    if diagnostics_count > 0
      let status_string = ""
      let status_string ..= (errors > 0 ? "E:"..errors : "")
      let status_string ..= (warnings > 0 ? "W:"..warnings : "")
      let status_string ..= (info > 0 ? "i:"..info : "")
      let status_string ..= (hints > 0 ? "?:"..hints : "")
    else
      let status_string = "OK"
    endif
    return "LSP: "..status_string
  endif
  return ""
endfunction
function! stl#git_stats()
  if empty(FugitiveGitDir()) || index(['fugitive', 'nerdtree'], &filetype) >= 0
    return ""
  endif
  let [a, m, r] = GitGutterGetHunkSummary()
  return printf("[+%d ~%d -%d]", a, m, r)
endfunction
