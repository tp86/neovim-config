local opt = vim.opt_local
local augroup = require("auto.helpers").ftgroup("go")

augroup("GoFiletype", {
  {
    "BufWritePre",
    callback = function()
      vim.lsp.buf.format()
    end,
  },
  {
    "BufWinEnter",
    callback = function()
      local chars = opt.listchars:get()
      chars.tab = "  "
      opt.listchars = chars
    end,
  },
  {
    "BufWinLeave",
    callback = function()
      opt.listchars = vim.opt_global.listchars:get()
    end,
  },
  {
    "BufWinEnter",
    "WinEnter",
    callback = function()
      opt.colorcolumn = {}
    end,
  },
})
