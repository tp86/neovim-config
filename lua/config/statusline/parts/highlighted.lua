local parts = require'config.statusline.parts'

local function highlight_part(part, hl_group)
    return '%#'..hl_group..'#'..part()..'%*'
end

return {
    cwd = function()
        local hl_cwd = 'Directory'
        return highlight_part(parts.cwd, hl_cwd)
    end,
    filename = function()
        local modified = vim.api.nvim_buf_get_option(0, 'modified')
        local readonly = vim.api.nvim_buf_get_option(0, 'readonly')
        local hl_filename = modified and 'WarningMsg' or readonly and 'Identifier' or 'Normal'
        return highlight_part(parts.filename, hl_filename)
    end
}
