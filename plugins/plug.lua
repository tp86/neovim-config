-- inspired by https://dev.to/vonheikemen/neovim-using-vim-plug-in-lua-3oom

do -- bootstrap
  local plug_file = vim.fn.stdpath("config") .. "/autoload/plug.vim"
  local function sync()
    vim.call("plug#begin") -- force sourcing of autoload
    vim.cmd [[ PlugInstall --sync ]]
    require("plugins.plug", true)
  end
  if not vim.loop.fs_stat(plug_file) then
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
    return
  end
end

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
    if type(plugin.config) == "function" then
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
  for _, config_fn in ipairs(start_configs) do
    config_fn()
  end
end

setup_plugins{}
