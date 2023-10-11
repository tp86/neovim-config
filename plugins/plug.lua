-- inspired by https://dev.to/vonheikemen/neovim-using-vim-plug-in-lua-3oom

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
    key = translate_key[key]
    if key then
      opts[key] = value
    end
  end
  return opts
end

local plug = vim.fn["plug#"]

local function get_name(plugin)
  return plugin[1]:match("^[%w-]+/([%s-_.]+])$")
end

local function is_lazy(plugin)
  return plugin.on or plugin["for"]
end

local function setup_plugins(plugins)
  local start_configs = {}
  vim.fn["plug#begin"]()
  for _, plugin in ipairs(plugins) do
    local repo = plugin[1]
    local opts = get_options(plugin)
    plug(repo, opts)
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
  vim.fn["plug#end"]()
  return start_configs
end

local function configure_plugins(configs)
  for _, config_fn in ipairs(configs) do
    config_fn()
  end
end

local function setup()
  local plugins = {
    { "EdenEast/nightfox.nvim",
      config = function()
        require("nightfox").setup {
          options = {
            styles = {
              comments = "",
            },
          },
        }
        vim.cmd("colorscheme duskfox")
      end,
    },
  }
  local configs = setup_plugins(plugins)
  local missing = false
  for _, plugin in pairs(vim.g.plugs) do
    if vim.fn.isdirectory(plugin.dir) == 0 then
      missing = true
      break
    end
  end
  return configs, missing
end

-- bootstrap
local plug_file = vim.fn.stdpath("config") .. "/autoload/plug.vim"

local function sync()
  local configs, changed = setup()
  if changed then
    vim.cmd("PlugInstall --sync")
  end
  configure_plugins(configs)
end

if vim.loop.fs_stat(plug_file) then
  sync()
else
  vim.loop.spawn("curl", {
    args = { "--create-dirs", "-fLo", plug_file, "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"},
  },
  function(code, signal)
    if code == 0 then
      if vim.v.vim_did_enter == 0 then -- still during startup
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
