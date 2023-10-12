-- probably need to provide python
local plugins = {}

local common = require("common")
common.with_dependencies({ "python3" }, function()

  table.insert(plugins, {
      "jmcantrell/vim-virtualenv",
      ["for"] = "python",
      on = { "VirtualEnvList", "VirtualEnvActivate" },
      config = function()
        local pynvim_directory = vim.fn.stdpath("config") .. "/pynvim"
        if not vim.loop.fs_stat(pynvim_directory) then
          vim.fn.system { "python3", "-m", "venv", pynvim_directory }
          vim.fn.system(("source %s/bin/activate && python -m pip install pynvim"):format(pynvim_directory))
        end
        local python3_path = pynvim_directory .. "/bin/python"
        vim.g.python3_host_prog = python3_path

        vim.g.virtualenv_directory = os.getenv("HOME") .. "/.venv"
      end,
  })
end, common.warn("vim-virtualenv is not installed due to: python3 is not available"))

return plugins
