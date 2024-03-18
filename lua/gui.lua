local function execute_if_command_exists(command)
  if vim.fn.exists(":" .. command:match("^%w+")) == 2 then
    vim.cmd(command)
  end
end

local group = vim.api.nvim_create_augroup("GuiConfig", { clear = true })
vim.api.nvim_create_autocmd("UIEnter", {
  group = group,
  callback = function()
    execute_if_command_exists("GuiFont! Hack:h14")
    vim.opt.guicursor = [[n-v-c-sm:block-Cursor,i-ci-ve:ver25-blinkwait200-blinkon500-blinkoff500,r-cr-o:hor20]]
    vim.opt.mouse = "a"
  end,
})
