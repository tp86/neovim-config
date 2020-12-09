" Lua fixes for different Lua versions in Neovim and different lua vim packages
" In Termux, Neovim 0.4.4 has Lua 5.3 instead of LuaJIT 2.1.0
lua << EOF
-- emulate vim.fn for Neovim version < 0.5.0
vim.fn = vim.fn or setmetatable({}, {
    __index = function(_, f)
        return function(...)
            return vim.api.nvim_call_function(f, {...})
        end
    end
})
-- loadstring deprecated since Lua 5.2
loadstring = loadstring or load
-- tbl_keys emulation
vim.tbl_keys = vim.tbl_keys or function(t)
    local keys = {}
    for k in pairs(t) do
        table.insert(keys, k)
    end
    return keys
end
-- tbl_count emulation
vim.tbl_count = vim.tbl_count or function(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end
EOF

" Helper for reloading Lua packages
function! s:lua_package_complete(...)
  return join(luaeval('vim.tbl_keys(package.loaded)'), "\n")
endfunction
command! -nargs=1 -complete=custom,s:lua_package_complete LuaReload lua package.loaded[<q-args>] = nil

language en_US.UTF-8

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
lua << EOF
local s = require'satiable'
local timestamp = 0
s.parts = {
  truncate = '%<',
  file = '%f',
  space = ' ',
  help_buffer = '%h',
  modified = '%m',
  read_only = '%r',
  alignment_separator = '%=',
  group_begin = '%-14.(',
  -- TODO in statusline:
  -- {
  --    format = '-14.',
  --    s.parts.group_begin
  -- }
  group_end = '%)',
  line = '%l',
  comma = ',',
  column = '%c',
  virtual_column = '%V',
  percentage = '%p',
  percent = '%%',
  wait = function()
    local t = os.clock()
    while os.clock() - t <= 0.5 do end
    return ''
  end,
  time_start = function()
    timestamp = os.clock()
    return ''
  end,
  time_end = function()
    vim.api.nvim_command('echomsg "spent: '..string.format('%.6f', os.clock() - timestamp)..'"')
    return ''
  end,
}
s.statusline = {
  s.parts.time_start,
  s.parts.truncate,
  s.parts.file,
  s.parts.space,
  s.parts.help_buffer,
  s.parts.modified,
  s.parts.read_only,
  s.parts.alignment_separator,
  s.parts.group_begin,
  s.parts.line,
  s.parts.comma,
  s.parts.column,
  s.parts.virtual_column,
  s.parts.group_end,
  s.parts.percentage,
  s.parts.percent,
  --s.parts.time_end,
}
EOF
set statusline=%!luaeval('require\''satiable\''.statusline()')
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
augroup help_maps
  autocmd!
  autocmd FileType help nnoremap <buffer> <cr> <c-]>
augroup end

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
