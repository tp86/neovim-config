local function with_dependencies(cmds, action, fallback)
  local all_present = true
  for _, cmd in ipairs(cmds) do
    if vim.fn.executable(cmd) ~= 1 then
      all_present = false
      break
    end
  end
  if all_present then
    return action()
  else
    return fallback()
  end
end

local function warn(msg)
  return function()
    vim.cmd [[ echohl WarningMsg ]]
    vim.cmd('echom "' .. msg .. '"')
    vim.cmd [[ echohl none ]]
  end
end

local map_opts = { noremap = true }
local function make_map(mode)
  return function(keys, action, desc, opts)
    opts = opts or {}
    opts.desc = desc
    opts = vim.tbl_extend("force", map_opts, opts)
    vim.keymap.set(mode, keys, action, opts)
  end
end

local nmap = make_map("n")
local imap = make_map("i")
local vmap = make_map("v")
local tmap = make_map("t")
local cmap = make_map("c")
local map = make_map("")

local function on_attach(_, bufnr)
  ---@diagnostic disable-next-line:redefined-local
  local map_opts = {
    noremap = true,
    silent = true,
    buffer = bufnr,
  }
  ---@diagnostic disable-next-line:redefined-local
  local function map(keys, action, description)
    return nmap(keys, action, description, map_opts)
  end

  -- set mappings only if LSP is connected
  map("gd", vim.lsp.buf.definition, "Go to definition")
  map("gr", vim.lsp.buf.references, "List references")
  map("gi", vim.lsp.buf.implementation, "List implementations")
  map("K", vim.lsp.buf.hover, "Show documentation")
  map("<localleader>r", vim.lsp.buf.rename, "Rename symbol")
  map("<localleader>=", function() vim.lsp.buf.format { async = true } end, "Format document")
  map("<localleader>a", vim.lsp.buf.code_action, "Code action")
end

local capabilities
local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok then
  capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
end

local function setup_lsp(config_name, server_name, settings)
  server_name = server_name or config_name
  with_dependencies({ server_name }, function()
    local lspconfig = require("lspconfig")
    lspconfig[config_name].setup {
      on_attach = on_attach,
      capabilities = capabilities,
      settings = settings,
    }
  end, warn(("%s not available"):format(server_name)))
end

local augroup_opts = { clear = true }
-- register autocmds in augroup
local function register_autocmds_group(group_name, cmds)
  local group = vim.api.nvim_create_augroup(group_name, augroup_opts)
  for _, cmd in ipairs(cmds) do
    local events, opts = {}, {}
    for key, value in pairs(cmd) do
      if type(key) == "number" then -- event name
        table.insert(events, value)
      else -- autocmd option
        opts[key] = value
      end
    end
    opts = vim.tbl_extend("keep", { group = group }, opts)
    vim.api.nvim_create_autocmd(events, opts)
  end
end

return {
  with_dependencies = with_dependencies,
  warn = warn,
  map = setmetatable({
    n = nmap,
    i = imap,
    v = vmap,
    t = tmap,
    c = cmap,
  }, { __call = function(_, ...) map(...) end }),
  lsp = {
    on_attach = on_attach,
    capabilities = capabilities,
    setup = setup_lsp,
  },
  register_autocmds_group = register_autocmds_group,
}
