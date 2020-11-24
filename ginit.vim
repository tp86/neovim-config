" settings specific for Neovim-Qt GUI
if exists("g:GuiLoaded")
  call GuiClipboard()
  GuiTabline 0
  GuiPopupmenu 0
  GuiFont! Hack:h12
endif
" guicursor (supported in Neovim-Qt since v0.2.16)
set guicursor=n-v-c-sm:block-Cursor
set guicursor+=i-ci-ve:ver25-blinkwait200-blinkon500-blinkoff500
set guicursor+=r-cr-o:hor20
