" manual setup needed:
"   - clipboard
"   - python

" temporary for development {{{1
unlet! s:vim_home
unlet! s:dir_sep
unlet! s:vim_home_
nnoremap <silent> <space>ws :w<cr>:so %<cr>

" base Neovim directory {{{1
const s:vim_home = expand(fnamemodify($MYVIMRC, ":p:h"))
if has("unix")
  const s:dir_sep = '/'
elseif has("win32")
  const s:dir_sep = '\'
endif
const s:vim_home_ = s:vim_home .. s:dir_sep

" python providers {{{1
if has("unix")
  let g:python3_host_prog = s:vim_home_ .. "pyenv/py3/bin/python"
endif

" Plugins {{{1
" automatic installation of vim-plug {{{2
" taken from https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
" requires DEP: curl
let s:plug_file = s:vim_home_ .. expand("autoload/plug.vim")
if empty(glob(s:plug_file))
  silent execute "!curl -fLo " .. s:plug_file .. " --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" plugins list {{{2
call plug#begin()
" colorschemes {{{3
Plug 'overcache/NeoSolarized'
" basic editing {{{3
" surrounds
Plug 'tpope/vim-surround'
" auto-closing parens
Plug 'tmsvg/pear-tree'
let g:pear_tree_ft_disabled = [
      \ "vim",
      \]
let g:pear_tree_repeatable_expand = v:false
let g:pear_tree_smart_openers = v:true
let g:pear_tree_smart_closers = v:true
let g:pear_tree_smart_backspace = v:true
" alignments
Plug 'junegunn/vim-easy-align'
" faster movements to certain point
Plug 'justinmk/vim-sneak'
let g:sneak#label = v:true
" comments
Plug 'tpope/vim-commentary'
" sessions {{{3
Plug 'xolox/vim-misc'
Plug 'xolox/vim-session'
let g:session_directory = s:vim_home_ .. "sessions"
set sessionoptions-=help
set sessionoptions+=resize
set sessionoptions+=winpos
let g:session_autoload = "yes"
let g:session_autosave = "yes"
let g:session_default_to_last = v:true
" git {{{3
Plug 'tpope/vim-fugitive'
Plug 'mhinz/vim-signify'
set updatetime=100
" virtual environments {{{3
Plug 'jmcantrell/vim-virtualenv'
let g:virtualenv_stl_format = '(%n)'
call plug#end()
" Settings {{{1
" colorscheme {{{2
set termguicolors
let $NVIM_TUI_ENABLE_TRUE_COLOR = v:true
let g:neosolarized_italic = v:true
set background=dark
colorscheme MyNeoSolarized
" interface {{{2
" numbered lines
set number relativenumber
set numberwidth=5
set signcolumn=yes
" no wrapping at end of line
set nowrap
" visibility of whitespace characters
let &listchars = "tab:\u00bb "
let &listchars ..= ",trail:\u00b7"
let &listchars ..= ",precedes:\u27ea"
let &listchars ..= ",extends:\u27eb"
set list
" scrolling offsets
set scrolloff=3
set sidescrolloff=10
" colored column at given length 80 and 120+
" background in inactive window colored
augroup color_column
  autocmd!
  autocmd BufNewFile,BufRead,BufWinEnter,WinEnter *
        \ let &l:colorcolumn = "80," .. join(range(120, 999), ",")
  autocmd WinLeave * let &l:colorcolumn = join(range(1, 999), ",")
augroup end
" mark cursor line
" not in windows where diff is enabled
augroup cursor_line
  autocmd!
  " enable cursorline in active window
  autocmd BufNewFile,BufRead,BufWinEnter,WinEnter *
        \ if &diff | setlocal nocursorline | else | setlocal cursorline | endif
  " toggle cursorline when diff option is set for active window
  autocmd OptionSet diff
        \ if v:option_new | setlocal nocursorline | else | setlocal cursorline | endif
  " disable cursorline in inactive windows
  autocmd WinLeave * setlocal nocursorline
augroup end
" statusline {{{3
function! s:statusline()
  let stl   = "%#stl_venv#%(%{VirtualEnvStatusline()} %)"
  let stl ..= "%#stl_cwd#%{pathshorten(fnamemodify(getcwd(), ':p')[:-2])}"
  let stl ..= "%#stl_git#%( (%{pathshorten(FugitiveHead(8))})%)%(%{sy#repo#get_stats_decorated()}%)"
  function! s:stl_filename()
    let bufname = bufname()
    let filename = fnamemodify(bufname, ":t")
    " special cases
    " filetype-based
    if index(["help"], &filetype) >= 0
      return filename
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
      return join(splitted_term_uri[0], shell_pid, shell_exec], ":")
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
  let stl ..= "%#stl_filename# %{" .. expand("<SID>") .. "stl_filename()} %m%r"
  let stl ..= "%*"
  let stl ..= "%="
  let stl ..= "%($[%{xolox#session#find_current_session()}] %)"
  function! s:stl_lsp()
    " TODO
    return 2
  endfunction
  let stl ..= "%(%#stl_lsp_ok#%{" .. expand("<SID>") .. "stl_lsp()==0?'o':''}" ..
        \      "%#stl_lsp_err#%{" .. expand("<SID>") .. "stl_lsp()==1?'x':''}" ..
        \      "%* %)"
  let stl ..= "\u2261%p%%"
  return stl
endfunction
function! s:statusline_nc()
  let stl   = "%{pathshorten(fnamemodify(getcwd(), ':p')[:-2])} "
  let stl ..= "%{" .. expand("<SID>") .. "stl_filename()} %m%r"
  let stl ..= "%*"
endfunction
  let stl ..= "%="
  return stl
endfunction
let &statusline = "%!" .. expand("<SID>") .. "statusline()"
augroup statusline
  autocmd!
  autocmd WinEnter,BufWinEnter * let &l:statusline = "%!" .. expand("<SID>") .. "statusline()"
  autocmd WinLeave * let &l:statusline = "%!" .. expand("<SID>") .. "statusline_nc()"
augroup end
" terminal {{{2
" use Esc for leaving insert mode in terminal
tnoremap <esc> <c-\><c-n>
augroup terminal_settings
  autocmd!
  autocmd TermOpen * setlocal nonumber norelativenumber signcolumn=no
  " disable side scrolling offset when entering terminal, remember siso option
  " value in terminal buffer
  autocmd TermOpen,BufEnter,WinEnter term://* let b:siso = &sidescrolloff | set sidescrolloff=0
  " enable side scrolling offset when leaving terminal, use remembered siso
  " option value
  autocmd BufLeave,WinLeave term://* let &sidescrolloff = b:siso
  " automatically enter insert mode when entering terminal
  autocmd TermOpen,BufEnter,WinEnter term://* startinsert
  " leave insert mode when leaving terminal
  autocmd TermLeave,BufLeave,WinLeave term://* stopinsert
augroup end
" actions running on terminal start {{{3
" python virtualenv activation 
" uses $VIRTUAL_ENV variable that should be set by DEP: vim-virtualenv plugin
augroup pyvenv_activation
  autocmd!
  function! s:activate_pyvenv()
    if exists("$VIRTUAL_ENV") && !empty(expand("$VIRTUAL_ENV"))
      " full path to virtual environment directory
      let pyvenv_path = fnamemodify(expand("$VIRTUAL_ENV"), ":p")
      " command that is running in terminal (usually, shell)
      let cmd = join(split(bufname(), ":")[2:-1], ":")
      if has("win32")
        let activation_script = expand(pyvenv_path .. "/Scripts/activate")
        " we might be running Bash on Windows inside terminal
        if cmd =~# '\vsh(\.|$)'
          " clear whole command line and source activation script restoring
          " correct slashes for terminal's shell
          let activation_cmd = "\<c-e><c-u>source " .. substitute(activation_script, '\', '/', "g")
        else
          " clear cmd line and append bat extension for Windows' cmd.exe
          let activation_cmd = "\<esc>" .. activation_script .. ".bat"
        endif
      elseif has("unix")
        let activation_script = expand(pyvenv_path .. "/bin/activate")
        let activation_cmd = "\<c-e><c-u>source " .. activation_script
      endif
      call chansend(getbufvar("%", "terminal_job_id"), activation_cmd .. "\<cr>")
    endif
  endfunction
  " every terminal except for terminals opened by FZF
  autocmd TermOpen *[^{FZF$}] call s:activate_pyvenv()
augroup end
" movements {{{2
" use Alt modifier for easy window switching regardless of mode
nnoremap <a-h> <c-w>h
nnoremap <a-j> <c-w>j
nnoremap <a-k> <c-w>k
nnoremap <a-l> <c-w>l
inoremap <a-h> <c-\><c-n><c-w>h
inoremap <a-j> <c-\><c-n><c-w>j
inoremap <a-k> <c-\><c-n><c-w>k
inoremap <a-l> <c-\><c-n><c-w>l
vnoremap <a-h> <c-w>h
vnoremap <a-j> <c-w>j
vnoremap <a-k> <c-w>k
vnoremap <a-l> <c-w>l
tnoremap <a-h> <c-\><c-n><c-w>h
tnoremap <a-j> <c-\><c-n><c-w>j
tnoremap <a-k> <c-\><c-n><c-w>k
tnoremap <a-l> <c-\><c-n><c-w>l
" more natural moving in wildmenu
if has("nvim-0.4.2")
  set wildcharm=<tab>
  cnoremap <expr> <left> wildmenumode() ? "\<up>" : "\<left>"
  cnoremap <expr> <right> wildmenumode() ? "\<down>" : "\<right>"
  cnoremap <expr> <up> wildmenumode() ? "\<left>" : "\<up>"
  cnoremap <expr> <down> wildmenumode() ? "\<right>" : "\<down>"
  cnoremap <expr> <c-h> wildmenumode() ? "\<up>" : "\<c-h>"
  cnoremap <expr> <c-l> wildmenumode() ? "\<down>" : "\<c-l>"
  cnoremap <expr> <c-k> wildmenumode() ? "\<left>" : "\<c-k>"
  cnoremap <expr> <c-j> wildmenumode() ? "\<right>" : "\<c-j>"
endif
" easier moving through various lists
inoremap <c-j> <c-n>
inoremap <c-k> <c-p>
" easier moving to beginning/end of line
noremap H ^
noremap L $
" easier switching between alternate buffers
nnoremap <backspace> <c-^>
" searching {{{2
set ignorecase
set smartcase
" highlight search results only while doing search
augroup searching_highlight
  autocmd!
  set nohlsearch
  autocmd CmdlineEnter /,\? set hlsearch
  autocmd CmdlineLeave /,\? set nohlsearch
augroup end
" easier searching of visually selected text
vnoremap / y/<c-r>"<cr>
vnoremap g/ /
" easier jumping through searches
let s:search_commands = {
      \ "forward": ["next", "first"],
      \ "backward": ["previous", "last"]
      \}
function! s:search_jump(direction)
  let commands = get(s:search_commands, a:direction, s:search_commands["forward"])
  function! s:try_jump(list_prefix, commands)
    try
      execute a:list_prefix .. a:commands[0]
    catch /E553:/
      execute a:list_prefix .. a:commands[1]
    endtry
  endfunction
  " if location list for window is available, go through its results
  if len(getloclist(0)) > 0
    call s:try_jump("l", commands)
  " if quickfix list is available, go through its results
  elseif len(getqflist()) > 0
    call s:try_jump("c", commands)
  " go through / register results
  else
    if a:direction ==# "forward"
      let search_key = "n"
    elseif a:direction ==# "backward"
      let search_key = "N"
    endif
    execute "normal! " .. search_key
  endif
endfunction
nnoremap <silent> ]s :<c-u>call <sid>search_jump("forward")<cr>
nnoremap <silent> [s :<c-u>call <sid>search_jump("backward")<cr>
" git {{{2
nnoremap <silent> cd <cmd>SignifyHunkDiff<cr>
nnoremap <silent> cu <cmd>SignifyHunkUndo<crs:>
" }}}
" vim:foldmethod=marker
