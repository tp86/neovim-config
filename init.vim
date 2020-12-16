" Fix Lua when using Neovim version < 0.5.0
lua << EOF
vim.fn = vim.fn or setmetatable({}, {
    __index = function(t, func)
        return function(...)
            return vim.api.nvim_call_function(func, {...})
        end
    end
})
EOF

let mapleader = ' '
let s:vim_home = fnamemodify($MYVIMRC, ':p:h')

" Plugins
let s:plug_file = expand(s:vim_home..'/autoload/plug.vim')
if empty(glob(s:plug_file))
  let s:curl = 'curl'
  if has('win32')
    let s:curl ..= '.exe'
  endif
  silent execute '!' .. s:curl .. ' -fLo ' .. s:plug_file .. ' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()

Plug 'overcache/NeoSolarized'
Plug 'tpope/vim-surround' " TODO which key
Plug 'tmsvg/pear-tree'
let g:pear_tree_ft_disabled = ['vim']
let g:pear_tree_smart_openers = 1
let g:pear_tree_smart_closers = 1
let g:pear_tree_smart_backspace = 1
Plug 'junegunn/vim-easy-align' " TODO which key
Plug 'justinmk/vim-sneak'
let g:sneak#label = v:true
Plug 'tpope/vim-commentary' " TODO which key
Plug 'junegunn/rainbow_parentheses.vim'
let g:rainbow#max_level = 24
augroup rainbow_activation
  autocmd!
  autocmd FileType clojure RainbowParentheses
augroup end
Plug 'xolox/vim-misc'
Plug 'xolox/vim-session'
let g:session_directory = expand(s:vim_home..'/sessions')
set sessionoptions-=help
set sessionoptions-=buffers
set sessionoptions+=resize
set sessionoptions+=winpos
let g:session_autoload = 'yes'
let g:session_autosave = 'yes'
let g:session_default_to_last = v:true
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
set updatetime=400
Plug 'preservim/nerdtree'
let g:NERDTreeWinSize = 40
let g:NERDTreeMapOpenVSplit = 'v'
let g:NERDTreeMapOpenSplit = 's'
let g:NERDTreeQuitOnOpen = v:true
" TODO which key
nnoremap <leader>e <cmd>NERDTreeToggleVCS<cr>
Plug 'Xuyuanp/nerdtree-git-plugin'
let g:NERDTreeGitStatusConcealBrackets = v:true
Plug 'tpope/vim-projectionist'
Plug 'neovim/nvim-lspconfig'

call plug#end()

set hidden

" UI settings
"" colors
set termguicolors
let $NVIM_TUI_ENABLE_TRUE_COLOR = v:true
set background=light
colorscheme my_colors

"" interface
set signcolumn=yes
set nowrap
let &listchars = join(["tab:\u00bb ", "trail:\u00b7", "precedes:\u27ea", "extends:\u27eb"], ',')
set list
set scrolloff=3
set sidescrolloff=6
augroup color_column
  autocmd!
  autocmd BufNewFile,BufRead,BufWinEnter,WinEnter *
        \ let &l:colorcolumn = join(insert(range(120, 999), 80), ',')
  autocmd WinLeave * let &l:colorcolumn = join(range(1, 999), ',')
augroup end
augroup cursor_line
  autocmd!
  autocmd BufNewFile,BufRead,BufWinEnter,WinEnter * let &l:cursorline = !&diff
  autocmd OptionSet diff let &l:cursorline = !v:option_new
  autocmd WinLeave * setlocal nocursorline
augroup end
"" open quickfix window always at the bottom of all windows
augroup quickfix_window
  autocmd!
  autocmd FileType qf wincmd J
augroup end

"" statusline
if has('nvim-0.5.0')
  set statusline=%!luaeval('require\''stl_tbl\''.statusline')
endif
"" tabline
" TODO

" terminal
tnoremap <esc> <c-\><c-n>
augroup terminal_config
  autocmd!
  autocmd TermOpen * setlocal nonumber norelativenumber signcolumn=no
  autocmd TermOpen,BufEnter,WinEnter term://* setlocal sidescrolloff=0
  autocmd TermOpen,BufWinEnter term://* startinsert
  autocmd TermLeave,BufLeave,WinLeave term://* stopinsert
augroup end
set scrollback=100000

"" terminal startup actions
" TODO

" movements
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
if has("nvim-0.4.2")
  set wildcharm=<tab>
  cnoremap <expr> <left>  wildmenumode() ? "\<up>" : "\<left>"
  cnoremap <expr> <right> wildmenumode() ? "\<down>" : "\<right>"
  cnoremap <expr> <up>    wildmenumode() ? "\<left>" : "\<up>"
  cnoremap <expr> <down>  wildmenumode() ? "\<right>" : "\<down>"
  cnoremap <expr> <c-h>   wildmenumode() ? "\<up>" : "\<c-h>"
  cnoremap <expr> <c-l>   wildmenumode() ? "\<down>" : "\<c-l>"
  cnoremap <expr> <c-k>   wildmenumode() ? "\<left>" : "\<c-k>"
  cnoremap <expr> <c-j>   wildmenumode() ? "\<right>" : "\<c-j>"
endif
inoremap <c-j> <c-n>
inoremap <c-k> <c-p>
noremap H ^
noremap L $
nnoremap <backspace> <c-^>

" editing & formatting
set clipboard+=unnamed  " win32yank / xclip installation may be needed

"" easy paste in insert mode
"" LUA
function! s:insert_put()
  let keys = "\<esc>g"
  if col(".") == 1
    let keys ..= 'P'
  else
    let keys ..= 'p'
  endif
  if col('.') == col('$')
    let keys ..= 'a'
  else
    let keys ..= 'i'
  endif
  return keys
endfunction
inoremap <expr> <a-v> <sid>insert_put()
tnoremap <c-v> <c-\><c-n>"+pa

set expandtab
set tabstop=4 softtabstop=4 shiftwidth=4
set shiftround
set smartindent
"" LUA
function! s:empty_lines(count, above)
  let current_position = getcurpos()
  let new_position = [current_position[1], current_position[4]]
  let line_to_insert = new_position[0]
  if a:above
    let line_to_insert = new_position[0] - 1
    let new_position[0] += a:count
  endif
  call append(line_to_insert, repeat([''], a:count))
  call cursor(new_position)
endfunction
nnoremap <silent> [<cr> :<c-u>call <sid>empty_lines(v:count1, v:true)<cr>
nnoremap <silent> ]<cr> :<c-u>call <sid>empty_lines(v:count1, v:false)<cr>
"" automatically replace tabs with spaces on saving
"" set g:autoretab to false to turn off this behavior
let g:autoretab = v:true
"" ...or invoke this command to toggle option
command! AutoRetabToggle let g:autoretab = !g:autoretab
augroup auto_retab
  autocmd!
  autocmd BufWrite * if g:autoretab | retab | endif
augroup end
"" automatically remove trailing spaces
"" set g:autoremove_trail_spaces to false to turn off this behavior
let g:autoremove_trail_spaces = v:true
"" ...or invoke this command to toggle option
command! AutoRemoveTrailSpaceToggle let g:autoremove_trail_spaces = !g:autoremove_trail_spaces
augroup auto_remove_trail_space
  autocmd!
  function! s:remove_trail_space()
    let view = winsaveview()  " store view to avoid cursor movement to last removed trailing space position
    try
      %s/\v\s+$//
    catch /E486:/  " no trailing spaces found, suppress error message
    endtry
    call winrestview(view)  " restore window view
  endfunction
  autocmd BufWrite * if g:autoremove_trail_spaces | call <sid>remove_trail_space() | endif
augroup end

" searching
"" TODO: swiper-like fuzzy searching in lines
set ignorecase
set smartcase
"" highlight matches only during searching
augroup searching_highlight
  autocmd!
  set nohlsearch
  autocmd CmdlineEnter /,\? set hlsearch
  autocmd CmdlineLeave /,\? set nohlsearch
augroup end
"" easier searching of visually selected text
vnoremap <c-s> y/<c-r>"<cr>
