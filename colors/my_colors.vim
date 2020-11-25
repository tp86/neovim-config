runtime colors/morning.vim

let &fillchars = "vert: "
highlight! link VertSplit StatusLineNC
highlight! link Folded FoldColumn
function! s:get_attr(group, attr)
  return synIDattr(synIDtrans(highlightID(a:group)), a:attr, "gui")
endfunction
function! s:dim(color, by)
  return "#"..printf("%06x", (nvim_get_color_by_name(a:color) - nvim_get_color_by_name(a:by)))
endfunction
execute "highlight ".."SignColumn".." guibg".."="..s:dim(s:get_attr("Normal", "bg"), "#080808")

let g:colors_name = "my_colors"
