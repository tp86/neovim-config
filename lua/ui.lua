local function execute_if_command_exists(command)
  if vim.fn.exists(":" .. command:match("^%w+")) == 2 then
    vim.cmd(command)
  end
end

local augroup = require("auto").augroup
augroup("GuiConfig", {
  {
    "UIEnter",
    callback = function()
      if vim.g.GuiLoaded then
        execute_if_command_exists("GuiFont! " .. vim.g.guifont)
        vim.opt.guicursor = [[n-v-c-sm:block-Cursor,i-ci-ve:ver25-blinkwait200-blinkon500-blinkoff500,r-cr-o:hor20]]
        vim.opt.mouse = "a"
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

-- set background automatically
local function set_background()
  local hour = os.date("*t").hour
  local background = "light"
  if hour < 8 or hour >= 19 then
    background = "dark"
  end
  if vim.opt.background:get() ~= background then
    vim.opt.background = background
  end
end
vim.fn.timer_start(1000 * 30, set_background, { ["repeat"] = -1 })
set_background()
