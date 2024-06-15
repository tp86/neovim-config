vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- setup python provider before any plugins
local pynvim_directory = vim.fn.stdpath("config") .. "/pynvim"
if not vim.loop.fs_stat(pynvim_directory) then
  vim.cmd [[ echomsg "Setting up python virtualenv for Neovim. This could take a while..." ]]
  vim.fn.system { "python3", "-m", "venv", pynvim_directory }
  vim.fn.system(
    ("source %s/bin/activate && python -m pip install pynvim jupyter_client")
    :format(pynvim_directory))
end
local python3_path = pynvim_directory .. "/bin/python"
vim.g.python3_host_prog = python3_path
