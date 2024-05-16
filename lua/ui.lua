local function execute_if_command_exists(command)
  if vim.fn.exists(":" .. command:match("^%w+")) == 2 then
    vim.cmd(command)
  end
end

local register_autocmds_group = require("common").register_autocmds_group
register_autocmds_group("GuiConfig", {
  {
    "UIEnter",
    callback = function()
      if vim.g.GuiLoaded then
        execute_if_command_exists("GuiFont! " .. vim.g.guifont)
        vim.opt.guicursor = [[n-v-c-sm:block-Cursor,i-ci-ve:ver25-blinkwait200-blinkon500-blinkoff500,r-cr-o:hor20]]
        vim.opt.mouse = "a"
        vim.opt.background = "light"
      end
    end,
    nested = true,
  },
  {
    "DirChanged",
    pattern = "global",
    callback = function(ev)
      vim.opt.titlestring = vim.fn.pathshorten(ev.file)
    end,
  }
})

vim.g.guifont = "Hack:h14"
vim.opt.title = true
vim.opt.titlestring = vim.fn.pathshorten(vim.fn.getenv("PWD"))
