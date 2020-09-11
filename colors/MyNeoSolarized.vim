" load base colorscheme
runtime plugged/NeoSolarized/colors/NeoSolarized.vim

let &fillchars = "vert: "
highlight! link VertSplit StatusLineNC
highlight! link SignColumn LineNr
highlight! link Folded FoldColumn

" statusline colors
let s:stl_fg = synIDattr(synIDtrans(highlightID("StatusLine")), "fg", "gui")
highlight! stl_venv guifg=#719e07 gui=reverse guibg=Black
highlight! stl_cwd guifg=#719e07 gui=bold,reverse guibg=White
highlight! stl_git guifg=#b58900
execute "highlight! stl_filename guifg=" .. s:stl_fg
execute "highlight! stl_lsp_ok guifg=#719e07 gui=bold guibg=" .. s:stl_fg
execute "highlight! stl_lsp_err guifg=#dc322f gui=bold guibg=" .. s:stl_fg

" signcolumn colors
let signcolumn_bg = synIDattr(synIDtrans(highlightID("SignColumn")), "bg", "gui")
let signcolumn_add = synIDattr(synIDtrans(highlightID("DiffAdd")), "fg", "gui")
let signcolumn_change = synIDattr(synIDtrans(highlightID("DiffChange")), "fg", "gui")
let signcolumn_delete = synIDattr(synIDtrans(highlightID("DiffDelete")), "fg", "gui")
execute "highlight! SignifySignAdd guifg=" .. signcolumn_add .. " guibg=" .. signcolumn_bg
execute "highlight! SignifySignChange guifg=" .. signcolumn_change .. " guibg=" .. signcolumn_bg
execute "highlight! SignifySignDelete guifg=" .. signcolumn_delete .. " guibg=" .. signcolumn_bg
execute "highlight! SignifySignChangeDelete guifg=" .. signcolumn_delete .. " guibg=" .. signcolumn_bg

highlight! link vimSet NONE
highlight! link vimSetEqual NONE

let g:colors_name = "MyNeoSolarized"
