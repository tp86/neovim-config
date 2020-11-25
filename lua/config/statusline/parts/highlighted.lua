local parts = require'config.statusline.parts'

local function highlight_part(part, hl_group)
    return '%#'..hl_group..'#'..part()..'%*'
end

local function highlight_filename(part)
    local modified = vim.api.nvim_buf_get_option(0, 'modified')
    local readonly = vim.api.nvim_buf_get_option(0, 'readonly')
    local hl_filename = modified and 'WarningMsg' or readonly and 'Identifier' or 'Normal'
    return highlight_part(part, hl_filename)
end

return {
    cwd = function()
        return highlight_part(parts.cwd, 'Directory')
    end,
    filename = function()
        return highlight_filename(parts.filename)
    end,
    relative_filename = function()
        return highlight_filename(parts.relative_filename)
    end,
}
