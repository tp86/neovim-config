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

let mapleader = " "

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
let &listchars = join(["tab:\u00bb ", "trail:\u00b7", "precedes:\u27ea", "extends:\u27eb"], ",")
set list
set scrolloff=3
set sidescrolloff=6
augroup color_column
  autocmd!
  autocmd BufNewFile,BufRead,BufWinEnter,WinEnter *
        \ let &l:colorcolumn = join(insert(range(120, 999), 80), ",")
  autocmd WinLeave * let &l:colorcolumn = join(range(1, 999), ",")
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
set statusline=%!statusline#active()
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
    let keys ..= "P"
  else
    let keys ..= "p"
  endif
  if col(".") == col("$")
    let keys ..= "a"
  else
    let keys ..= "i"
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
  call append(line_to_insert, repeat([""], a:count))
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
  "" LUA
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
