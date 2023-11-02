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
  local map_opts = {
    noremap = true,
    silent = true,
    buffer = bufnr,
  }
  -- set mappings only if LSP is connected
  nmap("gd", vim.lsp.buf.definition, "Go to definition", map_opts)
  nmap("gr", vim.lsp.buf.references, "List references", map_opts)
  nmap("K", vim.lsp.buf.hover, "Show documentation", map_opts)
  nmap("<localleader>r", vim.lsp.buf.rename, "Rename symbol", map_opts)
  nmap("<localleader>=", function() vim.lsp.buf.format { async = true } end, "Format document", map_opts)
end

local capabilities
local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok then
  capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
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
  },
  register_autocmds_group = register_autocmds_group,
}
