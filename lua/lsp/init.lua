local nvim_lsp = require'nvim_lsp'
local root_pattern = nvim_lsp.util.root_pattern
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
    vim.api.nvim_command("echomsg 'Starting LSP'")
    vim.lsp.set_log_level(0)
    completion.on_attach(client)
    diagnostic.on_attach(client)
    status.on_attach(client)

    vim.fn.LspBufCommands()
    -- ShowDiagnostic command is defined in init.vim
    vim.fn.nvim_buf_set_keymap(0, "n", "<c-l>?", "<cmd>ShowDiagnostic<cr>", {noremap = true, silent = true})
    vim.fn.nvim_buf_set_keymap(0, "n", "<c-l>D", "<cmd>PrevDiagnostic<cr>", {noremap = true, silent = true})
    vim.fn.nvim_buf_set_keymap(0, "n", "<c-l>d", "<cmd>NextDiagnostic<cr>", {noremap = true, silent = true})

    vim.fn.nvim_buf_set_keymap(0, "n", "<c-l>gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", {noremap = true, silent = true})
    vim.fn.nvim_buf_set_keymap(0, "n", "<c-l>gd", "<cmd>lua vim.lsp.buf.definition()<cr>", {noremap = true, silent = true})
    vim.fn.nvim_buf_set_keymap(0, "n", "<c-l>h", "<cmd>lua vim.lsp.buf.hover()<cr>", {noremap = true, silent = true})
    vim.fn.nvim_buf_set_keymap(0, "n", "<c-l>gy", "<cmd>lua vim.lsp.buf.implementation()<cr>", {noremap = true, silent = true})
    vim.fn.nvim_buf_set_keymap(0, "n", "<c-l>s", "<cmd>lua vim.lsp.buf.signature_help()<cr>", {noremap = true, silent = true})
    vim.fn.nvim_buf_set_keymap(0, "n", "<c-l>gt", "<cmd>lua vim.lsp.buf.type_definition()<cr>", {noremap = true, silent = true})
    vim.fn.nvim_buf_set_keymap(0, "n", "<c-l>r", "<cmd>lua vim.lsp.buf.references()<cr>", {noremap = true, silent = true})
    vim.fn.nvim_buf_set_keymap(0, "n", "<c-l>@", "<cmd>lua vim.lsp.buf.document_symbol()<cr>", {noremap = true, silent = true})
    vim.fn.nvim_buf_set_keymap(0, "n", "<c-l>W", "<cmd>lua vim.lsp.buf.workspace_symbol()<cr>", {noremap = true, silent = true})
    vim.fn.nvim_buf_set_keymap(0, "n", "<c-l>a", "<cmd>lua vim.lsp.buf.code_action()<cr>", {noremap = true, silent = true})
    vim.fn.nvim_buf_set_keymap(0, "n", "<c-l>n", "<cmd>lua vim.lsp.buf.rename()<cr>", {noremap = true, silent = true})
    vim.fn.nvim_buf_set_keymap(0, "n", "<c-l>=", "<cmd>lua vim.lsp.buf.formatting()<cr>", {noremap = true, silent = true})

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

nvim_lsp.clojure_lsp.setup{
    cmd = { "clojure-lsp.bat" },
    filetypes = { "clojure" },
    root_dir = root_pattern("project.clj", ".git"),
    init_options = {
        ["project-specs"] = {
            {
                ["project-path"] = "project.clj",
                ["classpath-cmd"] = { "lein.bat", "classpath" }
            }
        },
        ["dependency-scheme"] = { "jar" }
    },
    on_attach = custom_attach,
    capabilities = status.capabilities
}

local install_dir = function(server_name)
    return require'nvim_lsp/configs'[server_name].install_info().install_dir
end

nvim_lsp.jdtls.setup{
    cmd = {
        "java",
        "--add-modules=ALL-SYSTEM",
        "--add-opens", "java.base/java.util=ALL-UNNAMED",
        "--add-opens", "java.base/java.lang=ALL-UNNAMED",
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=ALL",
        -- "-noverify",
        "-Xms100m",
        "-Xmx1G",
        "-jar",
        install_dir("jdtls").."\\plugins\\org.eclipse.equinox.launcher_1.6.0.v20200915-1508.jar",
        "-configuration",
        install_dir("jdtls").."\\config_win",
        "-data",
        "C:\\Users\\tpalka\\.jdtls" },
    filetypes = { "java" },
    root_dir = root_pattern(".project", ".classpath", "pom.xml", ".git"),
    on_attach = custom_attach,
    capabilities = status.capabilities
}

-- nvim_lsp.yamlls.setup{
--     cmd = {
--         install_dir("yamlls").."\\bin\\yaml-language-server",
--         "--stdio"
--     },
--     filetypes = { "yaml" },
--     root_dir = root_pattern(".git", vim.fn.getcwd()),
--     on_attach = custom_attach,
--     capabilities = status.capabilities
-- }
