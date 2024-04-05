local plugins = {
  {
    "klen/nvim-config-local",
    config = function()
      require('config-local').setup {
        commands_create = true,
        silent = true,
        lookup_parents = true,
      }
      local common = require("common")
      common.register_autocmds_group("ConfigLocalReload", {
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
      local event = "DirChanged"
      local group_name = "config-local"
      local autocmd = vim.api.nvim_get_autocmds{
        group = group_name,
        event = event,
      }[1]
      if not autocmd then
        common.warn("DirChanged for config-local does not exist")
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

local common = require("common")
common.with_dependencies({ "python3" }, function()
  table.insert(plugins, {
    "jmcantrell/vim-virtualenv",
    ["for"] = "python",
    on = { "VirtualEnvList", "VirtualEnvActivate" },
    config = function()
      vim.g.virtualenv_directory = os.getenv("HOME") .. "/.venv"
    end,
  })
end, common.warn("vim-virtualenv is not installed due to: python3 is not available"))

return plugins
