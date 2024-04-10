-- open new tab with different directory
vim.api.nvim_create_user_command("Tab",
  function(args)
    vim.cmd.tabnew()
    vim.cmd.tcd(args.fargs[1])
  end,
  {
    nargs = 1,
    complete = "dir",
    desc = "Open directory in new tab",
    force = true
  }
)
