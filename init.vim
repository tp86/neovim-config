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
call plug#end()

" Settings {{{1
" colorscheme {{{2
set termguicolors
colorscheme NeoSolarized
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
" searching {{{2
" }}}
" vim:foldmethod=marker
