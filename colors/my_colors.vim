runtime colors/morning.vim

function! s:get_attr(group, attr)
  return synIDattr(synIDtrans(highlightID(a:group)), a:attr, "gui")
endfunction
function! s:darken(color, by)
  return "#"..printf("%06x", (nvim_get_color_by_name(a:color) - nvim_get_color_by_name(a:by)))
endfunction
function! s:lighten(color, by)
  return "#"..printf("%06x", (nvim_get_color_by_name(a:color) + nvim_get_color_by_name(a:by)))
endfunction

let &fillchars = "vert: "
highlight! link VertSplit StatusLineNC
highlight! link Folded FoldColumn
execute "highlight ".."SignColumn".." guibg".."="..s:darken(s:get_attr("Normal", "bg"), "#080808")

" statusline colors
"let s:stl_fg = synIDattr(synIDtrans(highlightID("StatusLine")), "fg", "gui")
let s:stl_bg = s:lighten(s:get_attr("Normal", "bg"), "#101010")
let s:stl_nc_bg = s:lighten("Black", "#606060")
execute "highlight! ".."StatusLine".." gui=NONE guifg=Black guibg="..s:stl_bg
execute "highlight! ".."StatusLineNC".." gui=NONE guifg=LightGray guibg="..s:stl_nc_bg

let s:stl_cwd_fg = "#399cbd"
execute "highlight! ".."StlCwd".." guifg="..s:stl_cwd_fg.." gui=bold guibg="..s:stl_bg
execute "highlight! ".."StlNCCwd".." guifg="..s:stl_cwd_fg.." gui=bold guibg="..s:stl_nc_bg

let s:stl_fname_mod_fg = "#ff2727"
let s:stl_fname_ro_fg = "#00c400"
execute "highlight! ".."StlFname".." gui=bold guifg=".."Black".." guibg="..s:stl_bg
execute "highlight! ".."StlNCFname".." gui=bold guifg=".."LightGray".." guibg="..s:stl_nc_bg
execute "highlight! ".."StlFnameMod".." gui=bold guifg="..s:stl_fname_mod_fg.." guibg="..s:stl_bg
execute "highlight! ".."StlNCFnameMod".." gui=bold guifg="..s:stl_fname_mod_fg.." guibg="..s:stl_nc_bg
execute "highlight! ".."StlFnameRo".." gui=bold guifg="..s:stl_fname_ro_fg.." guibg="..s:stl_bg
execute "highlight! ".."StlNCFnameRo".." gui=bold guifg="..s:stl_fname_ro_fg.." guibg="..s:stl_nc_bg

let g:colors_name = "my_colors"
