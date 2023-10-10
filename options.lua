local o = vim.opt
local tabs = 2

o.expandtab = true
o.tabstop = tabs
o.softtabstop = tabs
o.shiftwidth = tabs
o.shiftround = true

o.smartindent = true

o.hidden = true
o.termguicolors = true

o.number = true
o.relativenumber = true
o.numberwidth = 5
o.signcolumn = "yes"

o.wrap = false
o.list = true
o.listchars = {
  tab = "» ",
  trail = "·",
  precedes = "⟪",
  extends = "⟫",
}

o.scrolloff = 3
o.sidescrolloff = 12

o.ignorecase = true
o.smartcase = true

o.splitbelow = true
o.splitright = true

o.showmode = false

local common = require("common", true)
common.with_dependencies({ "rg" }, function()
  o.grepprg = "rg --line-number --column --with-filename"
  o.grepformat = "%f:%l:%c:%m"
end, common.warn "ripgrep not installed, falling back to grep")

o.clipboard:append("unnamedplus")

o.laststatus = 3

local dynamic_options = require("dynamic_options")
for name, value in pairs(dynamic_options) do
  o[name] = value
end
