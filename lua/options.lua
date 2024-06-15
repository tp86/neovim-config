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

local with_dependencies = require("utils.deps").with_dependencies
local log = require("utils.log")
with_dependencies({ "rg" }, function()
  o.grepprg = "rg --line-number --column --with-filename"
  o.grepformat = "%f:%l:%c:%m"
end, log.warn "ripgrep not installed, falling back to grep")

o.clipboard:append("unnamedplus")

o.laststatus = 3

vim.diagnostic.config {
  virtual_text = false,
}
o.updatetime = 1000

local dynamic_options = {
  colorcolumn = { 80 },
  hlsearch = false,
}
for name, value in pairs(dynamic_options) do
  o[name] = value
end

return {
  dynamic = dynamic_options,
}
