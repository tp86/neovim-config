local plugins = {
  {
    "klen/nvim-config-local",
    config = function()
      require('config-local').setup {
        commands_create = true,   -- Create commands (ConfigLocalSource, ConfigLocalEdit, ConfigLocalTrust, ConfigLocalIgnore)
        silent = false,           -- Disable plugin messages (Config loaded/ignored)
        lookup_parents = true,   -- Lookup config files in parent directories
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
