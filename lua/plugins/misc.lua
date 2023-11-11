local plugins = {
  {
    "klen/nvim-config-local",
    config = function()
      require('config-local').setup {
        commands_create = true,   -- Create commands (ConfigLocalSource, ConfigLocalEdit, ConfigLocalTrust, ConfigLocalIgnore)
        silent = false,           -- Disable plugin messages (Config loaded/ignored)
        lookup_parents = true,   -- Lookup config files in parent directories
      }
    end
  },
  {
    "jlcrochet/vim-crystal",
    ["for"] = "crystal",
    config = function()
      vim.g.crystal_simple_indent = 1
    end,
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
