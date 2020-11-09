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
" execute "highlight! stl_lsp_ok guifg=#719e07 gui=bold guibg=" .. s:stl_fg
" execute "highlight! stl_lsp_err guifg=#dc322f gui=bold guibg=" .. s:stl_fg

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

" LSP diagnostics colors are cleared on colorscheme reload
highlight! LspDiagnosticsError guifg=Red
highlight! link LspDiagnosticsErrorSign LspDiagnosticsError
highlight! link LspDiagnosticsErrorFloating LspDiagnosticsError
highlight! LspDiagnosticsWarning guifg=Orange
highlight! link LspDiagnosticsWarningSign LspDiagnosticsWarning
highlight! link LspDiagnosticsWarningFloating LspDiagnosticsWarning
highlight! LspDiagnosticsInformation guifg=LightBlue
highlight! link LspDiagnosticsInformationSign LspDiagnosticsInformation
highlight! link LspDiagnosticsInformationFloating LspDiagnosticsInformation
highlight! LspDiagnosticsHint guifg=LightGrey
highlight! link LspDiagnosticsHintSign LspDiagnosticsHint
highlight! link LspDiagnosticsHintFloating LspDiagnosticsHint

" GitGutter signs customization
highlight! GitGutterAdd guifg=Green guibg=White gui=reverse,bold
highlight! GitGutterChange guifg=Orange guibg=White gui=reverse,bold
highlight! GitGutterChangeDelete guifg=Red guibg=White gui=reverse,bold
highlight! GitGutterDelete guifg=Red guibg=White gui=reverse,bold

" Lsp highlights
let s:sign_bg_color = {
      \ "light": "#eee8d5",
      \ "dark": "#073642"
      \}
" References
execute "highlight! LspReferenceRead guifg=#00cc00 guibg="..s:sign_bg_color[&background]
execute "highlight! LspReferenceText guifg=#6666ff guibg="..s:sign_bg_color[&background]
execute "highlight! LspReferenceWrite guifg=#ff6666 guibg="..s:sign_bg_color[&background]
" Diagnostics
execute "highlight! LspDiagnosticsError guifg=#ff9999"
execute "highlight! LspDiagnosticsErrorSign guifg=Red"
sign define LspDiagnosticsErrorSign texthl=LspDiagnosticsErrorSign
highlight LspDiagnosticsUnderlineError gui=underline guifg=Red
execute "highlight! LspDiagnosticsWarning guifg=#ffcc99"
execute "highlight! LspDiagnosticsWarningSign guifg=Orange"
sign define LspDiagnosticsWarningSign texthl=LspDiagnosticsWarningSign
highlight LspDiagnosticsUnderlineWarning gui=underline guifg=Orange

let g:colors_name = "MyNeoSolarized"
