local with_dependencies = require("utils.deps").with_dependencies
local log = require("utils.log")
local nmap = require("mappings").map.n
local augroup = require("auto").augroup

-- show signature help automatically
-- inspired by: https://neovim.discourse.group/t/show-signature-help-on-insert-mode/2007/5
local function handler(original_handler)
  local win_opened = false
  return function(...)
    if win_opened then return end
    local buf, win = original_handler(...)
    if win then
      win_opened = true
      vim.api.nvim_create_autocmd({ "WinClosed" }, {
        pattern = tostring(win),
        callback = function()
          win_opened = false
        end,
        -- TODO once?
      })
    end
    return buf, win
  end
end
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
  handler(vim.lsp.handlers.signature_help),
  { focus = false, }
)

local function on_attach(client, bufnr)
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
  map("<c-k>", vim.lsp.buf.signature_help, "Toggle signature help")
  augroup("LspSignature", {
    {
      "CursorHoldI",
      buffer = bufnr,
      callback = vim.lsp.buf.signature_help,
    }
  })

  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
end

local capabilities
local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok then
  capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
end

local function setup(config_name, server_name, options)
  server_name = server_name or config_name
  with_dependencies({ server_name }, function()
    ---@diagnostic disable-next-line:redefined-local
    local ok, lspconfig = pcall(require, "lspconfig")
    if ok then
      options = options or {}
      options.capabilities = capabilities
      options.on_attach = on_attach
      lspconfig[config_name].setup(options)
    end
  end, log.warn(("%s not available"):format(server_name)))
end

local enabled_servers = {
  lua_ls = {
    server_name = "lua-language-server",
    config = {
      settings = {},
    },
  },
}

for config_name, opts in pairs(enabled_servers) do
  setup(config_name, opts.server_name, opts.config)
end

return {
  setup = setup,
}
