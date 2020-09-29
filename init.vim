" manual setup needed:
"   - clipboard
"   - python

" base Neovim directory {{{1
let s:vim_home = expand(fnamemodify($MYVIMRC, ":p:h"))
if has("unix")
  let s:dir_sep = '/'
elseif has("win32")
  let s:dir_sep = '\'
endif
let s:vim_home_ = s:vim_home .. s:dir_sep

" python providers {{{1
if has("unix")
  let g:python3_host_prog = s:vim_home_ .. "pyenv/py3/bin/python"
elseif has("win32")
  let g:python3_host_prog = s:vim_home_ .. "pyenv\\py3\\Scripts\\python.exe"
endif

let mapleader = " "
let maplocalleader = " "

" Plugins {{{1
" automatic installation of vim-plug {{{2
" taken from https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
" requires DEP: curl
let s:plug_file = s:vim_home_ .. expand("autoload/plug.vim")
if empty(glob(s:plug_file))
  let s:curl_cmd = "curl"
  " on Windows, neovim nightly comes with curl executable in Neovim's directory
  if has("win32")
    let s:curl_cmd ..= ".exe"
  endif
  silent execute "!" .. s:curl_cmd .. " -fLo " .. s:plug_file .. " --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
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

" rainbow parentheses (works only for some filetypes, lisps mostly)
Plug 'junegunn/rainbow_parentheses.vim'
let g:rainbow#max_level = 24

" sessions {{{3
Plug 'xolox/vim-misc'
Plug 'xolox/vim-session'
let g:session_directory = s:vim_home_ .. "sessions"
set sessionoptions-=help
set sessionoptions-=buffers
set sessionoptions+=resize
set sessionoptions+=winpos
let g:session_autoload = "yes"
let g:session_autosave = "yes"
let g:session_default_to_last = v:true

" git {{{3
Plug 'tpope/vim-fugitive'
" Plug 'mhinz/vim-signify'
Plug 'airblade/vim-gitgutter'
set updatetime=100
" let g:signify_sign_change = '~'

" virtual environments {{{3
" requires python provider setup
Plug 'jmcantrell/vim-virtualenv'
let g:virtualenv_stl_format = '(%n)'

" fuzzy search {{{3
Plug 'junegunn/fzf'
let g:fzf_layout = {"window": "botright 12 split enew"}
let g:fzf_action = {
      \ "ctrl-t": "tab split",
      \ "ctrl-s": "split",
      \ "ctrl-v": "vsplit",
      \}
Plug 'junegunn/fzf.vim'

" explorer {{{3
Plug 'preservim/nerdtree'
let g:NERDTreeWinSize = 40
let g:NERDTreeMapOpenVSplit = 'v'
let g:NERDTreeMapOpenSplit = 's'
let g:NERDTreeQuitOnOpen = v:true
nnoremap <leader>E <cmd>NERDTreeToggleVCS<cr>
Plug 'Xuyuanp/nerdtree-git-plugin'
let g:NERDTreeGitStatusConcealBrackets = v:true

" project {{{3
Plug 'tpope/vim-projectionist'

" snippets {{{3
Plug 'SirVer/Ultisnips'
let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"

" completion {{{3
function! ApplyPatch(patch)
  call system("git apply " .. s:vim_home_ .. "patches/" .. a:patch)
endfunction
Plug 'nvim-lua/completion-nvim', { 'do': ':call ApplyPatch(\"completion.patch\")' }
set completeopt=menuone,noinsert,noselect
augroup completion_nvim_every_buffer
  autocmd!
  autocmd BufEnter * lua require'completion'.on_attach()
augroup end
inoremap <silent><expr> <c-space> completion#trigger_completion()
let g:completion_enable_snippet = 'UltiSnips'
" use TAB for expanding snippets (as in UltiSnips) and confirming selections
let g:completion_confirm_key = ""
imap <expr> <tab> pumvisible() ? complete_info()["selected"] != "-1" ?
      \ "\<plug>(completion_confirm_completion)" : "\<c-e>\<tab>" : "\<tab>"
let g:completion_matching_strategy_list = ['exact']
let g:completion_matching_ignore_case = 1
let g:completion_trigger_keyword_length = 3
" v:true doesn't work here
let g:completion_trigger_on_delete = 1

" lsp {{{3
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/diagnostic-nvim'
let g:diagnostic_enable_virtual_text = 1
let g:space_before_virtual_text = 5
let g:diagnostic_enable_underline = 0
let g:diagnostic_insert_delay = 1
call sign_define("LspDiagnosticsErrorSign", {"text": "E", "texthl": "LspDiagnosticsError"})
call sign_define("LspDiagnosticsWarningSign", {"text": "W", "texthl": "LspDiagnosticsWarning"})
call sign_define("LspDiagnosticsInformationSign", {"text": "i", "texthl": "LspDiagnosticsInformation"})
call sign_define("LspDiagnosticsHintSign", {"text": "?", "texthl": "LspDiagnosticsHint"})
Plug 'nvim-lua/lsp-status.nvim'
" Plug 'RishabhRD/popfix'
" Plug 'RishabhRD/nvim-lsputils'

call plug#end()

" Settings {{{1

set hidden

" colorscheme {{{2
set termguicolors
let $NVIM_TUI_ENABLE_TRUE_COLOR = v:true
let g:neosolarized_italic = v:true
set background=light
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
  let stl ..= "%#stl_git#%( (%{pathshorten(FugitiveHead(8))})%)"
  let stl ..= "%#stl_filename# %{stl#filename()} %m%r"
  let stl ..= "%*"
  let stl ..= "%="
  let stl ..= "%(%{stl#lsp()} %)"
  let stl ..= "%($[%{xolox#session#find_current_session()}] %)"
  let stl ..= "\u2261%p%%"
  return stl
endfunction
function! s:statusline_nc()
  let stl   = "%{pathshorten(fnamemodify(getcwd(), ':p')[:-2])} "
  let stl ..= "%{stl#filename()} %m%r"
  let stl ..= "%*"
  let stl ..= "%="
  return stl
endfunction
let &statusline = "%!" .. expand("<SID>") .. "statusline()"
augroup statusline
  autocmd!
  autocmd WinEnter,BufWinEnter * let &l:statusline = "%!" .. expand("<SID>") .. "statusline()"
  autocmd WinLeave * let &l:statusline = "%!" .. expand("<SID>") .. "statusline_nc()"
augroup end

" tabline {{{3
function! s:tabline()
  let tbl = ""
  function! s:tabpage_label(tabpagenr)
    if a:tabpagenr == tabpagenr()
      let label = "%#TablineSel#"
    else
      let label = "%#Tabline#"
    endif
    let label ..= "%" .. a:tabpagenr .. "T "
    let label ..= "%{tbl#tabline_modified(" .. a:tabpagenr .. ")} "
    let label ..= "%{tbl#tabline_filename(" .. a:tabpagenr .. ")} "
    let label ..= a:tabpagenr .. "|"
    return label
  endfunction
  for tabpagenr in range(1, tabpagenr("$"))
    let tbl ..= s:tabpage_label(tabpagenr)
  endfor
  let tbl ..= "%#TablineFill#"
  let tbl ..= "%="
  return tbl
endfunction
let &tabline = "%!" .. expand("<SID>") .. "tabline()"

" terminal {{{2
" use Esc for leaving insert mode in terminal
" except for terminals opened by FZF
tnoremap <expr> <esc> &filetype =~# 'fzf' ? "\<esc>" : "\<c-\>\<c-n>"
augroup terminal_settings
  autocmd!
  autocmd TermOpen * setlocal nonumber norelativenumber signcolumn=no
  " disable side scrolling offset when entering terminal, remember siso option
  " value in terminal buffer
  autocmd TermOpen,BufEnter,WinEnter term://* setlocal sidescrolloff=0
  " " enable side scrolling offset when leaving terminal, use remembered siso
  " " option value
  " autocmd BufLeave,WinLeave term://* if exists("b:siso") | let &sidescrolloff = b:siso | else | set sidescrolloff< | endif
  " automatically enter insert mode when entering terminal
  autocmd TermOpen,BufWinEnter term://* startinsert
  " leave insert mode when leaving terminal
  autocmd TermLeave,BufLeave,WinLeave term://* stopinsert
augroup end
set scrollback=100000

" actions running on terminal start {{{3
" python virtualenv activation
" uses $VIRTUAL_ENV variable that should be set by DEP: vim-virtualenv plugin
augroup terminal_pyvenv_activation
  autocmd!
  function! s:activate_pyvenv()
    if exists("$VIRTUAL_ENV") && !empty(expand("$VIRTUAL_ENV"))
      " full path to virtual environment directory
      let pyvenv_path = fnamemodify(expand("$VIRTUAL_ENV"), ":p")
      " command that is running in terminal (usually, shell)
      let cmd = join(split(bufname(), ":")[2:-1], ":")
      if has("win32")
        let activation_script = expand(pyvenv_path .. "Scripts/activate")
        " we might be running Bash on Windows inside terminal
        if cmd =~# '\vsh(\.|$)'
          " clear whole command line and source activation script restoring
          " correct slashes for terminal's shell
          let activation_cmd = "\<c-e>\<c-u>source " .. substitute(activation_script, '\', '/', "g")
        else
          " clear cmd line and append bat extension for Windows' cmd.exe
          let activation_cmd = "\<esc>" .. activation_script .. ".bat"
        endif
      elseif has("unix")
        let activation_script = expand(pyvenv_path .. "bin/activate")
        let activation_cmd = "\<c-e>\<c-u>source " .. activation_script
      endif
      call chansend(getbufvar("%", "terminal_job_id"), activation_cmd .. "\<cr>")
    endif
  endfunction
  function! s:terminal_on_open()
    call s:activate_pyvenv()
  endfunction
  " every terminal except for terminals opened by FZF
  autocmd TermOpen *[^{FZF$}] call <sid>terminal_on_open()
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

" formatting {{{2
set expandtab
set tabstop=4 softtabstop=4 shiftwidth=4 shiftround
set smartindent
" adding empty lines above/below current line
function s:empty_lines(count, above)
  let current_position = getcurpos()
  let new_position = [current_position[1], current_position[4]]
  let line_to_insert = new_position[0]
  if a:above
    let line_to_insert = new_position[0] - 1
    let new_position[0] += a:count
  endif
  call append(line_to_insert, repeat([""], a:count))
  call cursor(new_position)
endfunction
nnoremap <silent> [<space> :<c-u>call <sid>empty_lines(v:count1, v:true)<cr>
nnoremap <silent> ]<space> :<c-u>call <sid>empty_lines(v:count1, v:false)<cr>
" automatically replace tabs with spaces on saving
" set this to false to turn off this behavior
let g:autoretab = v:true
command! AutoRetabToggle let g:autoretab = !g:autoretab
augroup auto_retab
  autocmd!
  autocmd BufWrite * if g:autoretab | retab | endif
augroup end
" automatically remove trailing spaces
" set this to false to turn off this behavior
let g:autoremove_trail_spaces = v:true
command! AutoRemoveTrailSpaceToggle let g:autoremove_trail_spaces = !g:autoremove_trail_spaces
augroup auto_remove_trail_space
  autocmd!
  function! s:remove_trail_space()
    let view = winsaveview()
    try
      %s/\v\s+$//
    catch /E486:/
    endtry
    call winrestview(view)
  endfunction
  autocmd BufWrite * if g:autoremove_trail_spaces | call <sid>remove_trail_space() | endif
augroup end

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

" layout automation {{{2
augroup quickfix_window
  autocmd!
  autocmd FileType qf wincmd J
augroup end

" git {{{2
nnoremap <silent> cd <cmd>GitGutterPreviewHunk<cr>
nnoremap <silent> cu <cmd>GitGutterUndoHunk<cr>

" git & fuzzy search {{{2
" searching and switching to git branches
function! s:execute_git(git_dir, command)
  let git_dir = a:git_dir
  if fnamemodify(git_dir, ":t") =~# '\v\.git$'
    let git_dir = fnamemodify(git_dir, ":h")
  endif
  if empty(git_dir)
    return[]
  endif
  let git_command = printf("git --git-dir=%s --work-tree=%s %s",
        \ expand(git_dir .. "/.git"),
        \ git_dir,
        \ a:command
        \)
  return map(systemlist(git_command), {_, l -> trim(l)})
endfunction
function! GitBranches()
  let dict = {
        \ "source": filter(s:execute_git(FugitiveGitDir(), "branch -a"),
        \           {_, b -> !empty(b) && b !~# '\v^\s*remotes/.{-}/HEAD\s+-\>\s+'})
        \}
  function! dict.sink(lines)
    if a:lines !~# '\v^\s*\*'
      let branch = matchstr(a:lines, '\v^(\s*remotes/.{-}/)?\zs.*\ze$')
      execute "Git checkout " .. branch
    endif
  endfunction
  call fzf#run(fzf#wrap(dict))
endfunction
command! GitBranches call GitBranches()

" LSPs {{{2
" called during LSP server setup for buffer
function! LspBufCommands()
  function! s:lsp_reload_client()
    lua vim.lsp.stop_client(vim.lsp.buf_get_clients())
    w
    e
  endfunction
  command! -buffer LspReload call <sid>lsp_reload_client()
  command! -buffer LspCodeAction lua vim.lsp.buf.code_action()
  command! -buffer ShowDiagnostic lua vim.lsp.util.show_line_diagnostics()
  command! -buffer LspIncomingCalls lua vim.lsp.buf.incoming_calls()
  command! -buffer LspOutgoingCalls lua vim.lsp.buf.outgoing_calls()
endfunction
lua require'lsp'

" }}}
" vim:foldmethod=marker
