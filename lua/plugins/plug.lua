-- inspired by https://dev.to/vonheikemen/neovim-using-vim-plug-in-lua-3oom

local plugins_submodules = {
  "colors",
  "ui",
  "nvim-extensions",
  "editing",
  "terminal",
  "files",
  "searching",
  "git",
  "syntax",
  "misc",
}

local translate_key = setmetatable({
  build = "do",
}, {
  __index = function(_, key)
    if type(key) == "string" then return key end
  end
})

local function get_options(plugin)
  local opts = {}
  for key, value in pairs(plugin) do
    local translated_key = translate_key[key]
    if translated_key then
      opts[translated_key] = value
    end
  end
  return opts
end

local plug = vim.fn["plug#"]

local function get_name(plugin)
  return plugin[1]:match("^[%w-]+/([%w-_.]+)$")
end

local function is_lazy(plugin)
  return plugin.on or plugin["for"]
end

local function register_plugins(plugins)
  local start_configs = {}
  vim.call("plug#begin")
  for _, plugin in ipairs(plugins) do
    local repo = plugin[1]
    local opts = get_options(plugin)
    if next(opts) then
      plug(repo, opts)
    else
      plug(repo)
    end
    local config = plugin.config
    if type(config) == "function" then
      local name = plugin.as or get_name(plugin)
      if is_lazy(plugin) then
        vim.api.nvim_create_autocmd("User", {
          pattern = name,
          callback = config,
          once = true,
        })
      else
        table.insert(start_configs, config)
      end
    end
  end
  vim.call("plug#end")
  return start_configs
end

local function configure_plugins(configs)
  for _, config_fn in ipairs(configs) do
    config_fn()
  end
end

local function extend(tbl, plugins_submodule)
  local plugins = require("plugins." .. plugins_submodule, true)
  for _, plugin in ipairs(plugins) do
    table.insert(tbl, plugin)
  end
end

local function get_configs()
  local plugins = {}
  for _, submodule in ipairs(plugins_submodules) do
    extend(plugins, submodule)
  end
  return register_plugins(plugins)
end

-- bootstrap
local plug_file = vim.fn.stdpath("config") .. "/autoload/plug.vim"

local fs_stat = vim.loop.fs_stat

local function missing()
  for _, plugin in pairs(vim.g.plugs) do
    if (fs_stat(plugin.dir) or {}).type ~= "directory" then
      return true
    end
  end
end

local function sync()
  local configs = get_configs()
  if missing() then
    vim.cmd("PlugInstall --sync")
  end
  configure_plugins(configs)
end

if fs_stat(plug_file) then
  sync()
else
  vim.loop.spawn("curl", {
    args = { "--create-dirs", "-fLo", plug_file, "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"},
  },
  function(code, signal)
    if code == 0 then
      if vim.v.vim_did_enter == 0 then -- still during startup, very unlikely
        vim.defer_fn(function()
          vim.api.nvim_create_autocmd("VimEnter", {
            callback = sync,
          })
        end, 0)
      else
        vim.defer_fn(function()
          sync()
        end, 0)
      end
    end
  end)
end
