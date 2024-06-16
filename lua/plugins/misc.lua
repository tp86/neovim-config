local augroup = require("auto").augroup
local with_dependencies = require("utils.deps").with_dependencies
local log = require("utils.log")

local plugins = {
  {
    "klen/nvim-config-local",
    config = function()
      require('config-local').setup {
        commands_create = true,
        silent = true,
        lookup_parents = true,
      }
      augroup("ConfigLocalReload", {
        {
          "User",
          pattern = "ConfigLocalFinished",
          -- command = "silent! edit",
          callback = function()
            vim.api.nvim_buf_set_option(0, 'filetype', vim.api.nvim_buf_get_option(0, 'filetype'))
          end,
        }
      })
      -- fix for DirChanged autocmd to trigger nested autocmds
      local group_name = "config-local"
      local event = "DirChanged"
      local autocmd = (vim.api.nvim_get_autocmds{
        group = group_name,
        event = event,
      } or {})[1]
      if not autocmd then
        log.warn("DirChanged for config-local does not exist")
        return
      end
      vim.api.nvim_del_autocmd(autocmd.id)
      vim.api.nvim_create_autocmd(event, {
        group = autocmd.group,
        pattern = autocmd.pattern,
        desc = autocmd.desc,
        callback = autocmd.callback,
        once = autocmd.once,
        nested = true,
      })
    end
  },
}

with_dependencies({ "python3" }, function()
  table.insert(plugins, {
    "jmcantrell/vim-virtualenv",
    ["for"] = "python",
    on = { "VirtualEnvList", "VirtualEnvActivate" },
    config = function()
      vim.g.virtualenv_directory = os.getenv("HOME") .. "/.venv"
    end,
  })
end, log.warn("vim-virtualenv is not installed due to: python3 is not available"))

return plugins
