local nvim_lsp = require'nvim_lsp'
local completion = require'completion'
local diagnostic = require'diagnostic'
-- local code_action = require'lsputil.codeAction'
-- local locations = require'lsputil.locations'
-- local symbols = require'lsputil.symbols'
local status = require'lsp-status'
status.register_progress()
status.config({
    indicator_errors = 'E',
    indicator_warnings = 'W',
    indicator_info = 'i',
    indicator_hint = '?',
    indicator_ok = '-',
    status_symbol = 'LSP: '
})

local custom_attach = function(client)
    completion.on_attach(client)
    diagnostic.on_attach(client)
    status.on_attach(client)

    vim.fn.LspBufCommands()
    -- ShowDiagnostic command is defined in init.vim
    vim.fn.nvim_buf_set_keymap(0, "n", "g?", "<cmd>ShowDiagnostic<cr>", {noremap = true, silent = true})
    vim.fn.nvim_buf_set_keymap(0, "n", "[d", "<cmd>PrevDiagnostic<cr>", {noremap = true, silent = true})
    vim.fn.nvim_buf_set_keymap(0, "n", "]d", "<cmd>NextDiagnostic<cr>", {noremap = true, silent = true})

    vim.fn.nvim_buf_set_keymap(0, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", {noremap = true, silent = true})
    vim.fn.nvim_buf_set_keymap(0, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", {noremap = true, silent = true})
    vim.fn.nvim_buf_set_keymap(0, "n", "gh", "<cmd>lua vim.lsp.buf.hover()<cr>", {noremap = true, silent = true})
    vim.fn.nvim_buf_set_keymap(0, "n", "gy", "<cmd>lua vim.lsp.buf.implementation()<cr>", {noremap = true, silent = true})
    vim.fn.nvim_buf_set_keymap(0, "n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", {noremap = true, silent = true})
    vim.fn.nvim_buf_set_keymap(0, "n", "gT", "<cmd>lua vim.lsp.buf.type_definition()<cr>", {noremap = true, silent = true})
    vim.fn.nvim_buf_set_keymap(0, "n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", {noremap = true, silent = true})
    vim.fn.nvim_buf_set_keymap(0, "n", "<leader>@", "<cmd>lua vim.lsp.buf.document_symbol()<cr>", {noremap = true, silent = true})
    vim.fn.nvim_buf_set_keymap(0, "n", "<leader>W", "<cmd>lua vim.lsp.buf.workspace_symbol()<cr>", {noremap = true, silent = true})
    vim.fn.nvim_buf_set_keymap(0, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<cr>", {noremap = true, silent = true})
    vim.fn.nvim_buf_set_keymap(0, "n", "<leader><f2>", "<cmd>lua vim.lsp.buf.rename()<cr>", {noremap = true, silent = true})
    vim.fn.nvim_buf_set_keymap(0, "n", "<leader>=", "<cmd>lua vim.lsp.buf.formatting()<cr>", {noremap = true, silent = true})

    vim.api.nvim_command [[autocmd CursorHold  <buffer> lua vim.lsp.buf.clear_references();vim.lsp.buf.document_highlight()]]
    vim.api.nvim_command [[autocmd CursorHoldI <buffer> lua vim.lsp.buf.clear_references();vim.lsp.buf.document_highlight()]]
    vim.api.nvim_command [[autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()]]

    -- TODO: completion for server commands
    -- vim.api.nvim_command("command! -buffer -nargs=1 LspServerCommand :lua vim.lsp.buf.execute_command(<q-args>)<cr>")

    -- vim.lsp.callbacks['textDocument/codeAction'] = code_action.code_action_handler
    -- vim.lsp.callbacks['textDocument/references'] = locations.references_handler
    -- vim.lsp.callbacks['textDocument/definition'] = locations.definition_handler
    -- vim.lsp.callbacks['textDocument/declaration'] = locations.declaration_handler
    -- vim.lsp.callbacks['textDocument/typeDefinition'] = locations.typeDefinition_handler
    -- vim.lsp.callbacks['textDocument/implementation'] = locations.implementation_handler
    -- vim.lsp.callbacks['textDocument/documentSymbol'] = symbols.document_handler
    -- vim.lsp.callbacks['workspace/symbol'] = symbols.workspace_handler
    print("LSP started.")
end

nvim_lsp.pyls.setup{
    cmd = { "pyls" },
    filetypes = { "python" },
    root_dir = function(fname)
        return nvim_lsp.util.find_git_ancestor(fname) or vim.loop.cwd()
    end,
    on_attach = custom_attach,
    capabilities = status.capabilities
}

nvim_lsp.vimls.setup{
    on_attach = custom_attach,
    capabilities = status.capabilities
}
