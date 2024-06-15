local opt = vim.opt_local
opt.expandtab = false
opt.colorcolumn = {}
opt.listchars.tab = "  "

local augroup = require("auto").augroup
augroup("GoFmt", {
  {
    "BufWritePre",
    pattern = "*.go",
    callback = function()
      vim.lsp.buf.format()
    end,
  }
})
