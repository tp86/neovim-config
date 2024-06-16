local augroup_opts = { clear = true }
-- register autocmds in augroup
local function augroup(group_name, cmds)
  local group = vim.api.nvim_create_augroup(group_name, augroup_opts)
  for _, cmd in ipairs(cmds) do
    local events, opts = {}, {}
    for key, value in pairs(cmd) do
      if type(key) == "number" then -- event name
        table.insert(events, value)
      else                          -- autocmd option
        opts[key] = value
      end
    end
    opts = vim.tbl_extend("keep", { group = group }, opts)
    vim.api.nvim_create_autocmd(events, opts)
  end
end

local dynamic_options = require("options").dynamic
-- helper for synchronizing dynamic option changes
local function sync_dynamic_option(opt_name)
  -- return autocmd definition in format expected by `augroup`
  return {
    "OptionSet",
    pattern = opt_name,
    callback = function()
      dynamic_options[opt_name] = vim.v.option_new
    end,
  }
end

local function ftgroup(filetype)
  return function(group, autocmds)
    for _, autocmd in ipairs(autocmds) do
      if vim.list_contains(autocmd, "FileType") then
        autocmd.pattern = filetype
      else
        autocmd.pattern = "*." .. filetype
      end
    end
    augroup(group, autocmds)
  end
end

return {
  augroup = augroup,
  ftgroup = ftgroup,
  sync_dynamic_option = sync_dynamic_option,
}

