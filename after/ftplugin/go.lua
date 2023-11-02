local opt = vim.opt_local
opt.expandtab = false

local register_autocmds_group = require("common").register_autocmds_group
register_autocmds_group("GoFmt", {
  {
    "BufWritePre",
    pattern = "*.go",
    callback = function()
      print("formatting")
      vim.lsp.buf.format()
    end,
  }
})
