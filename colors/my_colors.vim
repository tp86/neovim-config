runtime colors/NeoSolarized.vim

function! s:get_attr(group, attr)
  return synIDattr(synIDtrans(highlightID(a:group)), a:attr, "gui")
endfunction
function! s:darken(color, by)
  return "#"..printf("%06x", (nvim_get_color_by_name(a:color) - nvim_get_color_by_name(a:by)))
endfunction
function! s:lighten(color, by)
  return "#"..printf("%06x", (nvim_get_color_by_name(a:color) + nvim_get_color_by_name(a:by)))
endfunction

" solarized colors
let s:base_colors = {
      \ "dark": {
      \   "primary_bg": "#002b36",
      \   "secondary_bg": "#073642",
      \   "secondary_content": "#586e75",
      \   "primary_content": "#839496",
      \   "emphasized": "#93a1a1",
      \ },
      \ "light": {
      \   "primary_bg": "#fdf6e3",
      \   "secondary_bg": "#eee8d5",
      \   "secondary_content": "#93a1a1",
      \   "primary_content": "#657b83",
      \   "emphasized": "#586e75",
      \ }
      \}
let s:accent_colors = {
      \ "yellow": "#b58900",
      \ "orange": "#cb4b16",
      \ "red": "#dc322f",
      \ "magenta": "#d33682",
      \ "violet": "#6c71c4",
      \ "blue": "#268bd2",
      \ "cyan": "#2aa198",
      \ "green": "#859900",
      \}

let &fillchars = "vert: "
highlight! link VertSplit StatusLineNC
highlight! link Folded FoldColumn
execute "highlight ".."SignColumn".." guibg".."="..s:darken(s:get_attr("Normal", "bg"), "#080808")

" statusline colors
"let s:stl_fg = synIDattr(synIDtrans(highlightID("StatusLine")), "fg", "gui")
"let s:stl_bg = s:lighten(s:get_attr("Normal", "bg"), "#02090a")
let s:stl_bg = {
      \ "light": "White",
      \ "dark": "Black",
      \}
let s:stl_fg = s:base_colors[&background].emphasized
"let s:stl_nc_bg = s:lighten("Black", "#606060")
let s:stl_nc_bg = s:base_colors[&background].secondary_content
let s:stl_nc_fg = s:base_colors[&background].secondary_bg
"let s:stl_nc_bg = s:lighten("Black", "#606060")
execute "highlight! ".."StatusLine".." gui=NONE guifg="..s:stl_fg.." guibg="..s:stl_bg[&background]
execute "highlight! ".."StatusLineNC".." gui=NONE guifg="..s:stl_nc_fg.." guibg="..s:stl_nc_bg

let s:stl_cwd_fg = s:accent_colors.cyan
execute "highlight! ".."StlCwd".." guifg="..s:stl_cwd_fg.." gui=bold guibg="..s:stl_bg[&background]
execute "highlight! ".."StlNCCwd".." guifg="..s:stl_cwd_fg.." gui=bold guibg="..s:stl_nc_bg

let s:stl_fname_mod_fg = s:accent_colors.red
let s:stl_fname_ro_fg = s:accent_colors.green
execute "highlight! ".."StlFname".." gui=bold guibg="..s:stl_bg[&background]
execute "highlight! ".."StlNCFname".." gui=bold guifg="..s:base_colors[&background].secondary_bg.." guibg="..s:stl_nc_bg
execute "highlight! ".."StlFnameMod".." gui=bold guifg="..s:stl_fname_mod_fg.." guibg="..s:stl_bg[&background]
execute "highlight! ".."StlNCFnameMod".." gui=bold guifg="..s:stl_fname_mod_fg.." guibg="..s:base_colors[&background].secondary_bg
execute "highlight! ".."StlFnameRo".." gui=bold guifg="..s:stl_fname_ro_fg.." guibg="..s:stl_bg[&background]
execute "highlight! ".."StlNCFnameRo".." gui=bold guifg="..s:stl_fname_ro_fg.." guibg="..s:base_colors[&background].secondary_bg

highlight! link vimSet NONE
highlight! link vimSetEqual NONE

let g:colors_name = "my_colors"
