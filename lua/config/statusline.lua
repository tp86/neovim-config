local stl_module = {}

local parts = {
    cwd = function()
        local full_cwd_path = vim.fn.fnamemodify(vim.fn.getcwd(), ':p')
        local cwd_len = string.len(full_cwd_path)
        local path_sep = string.sub(full_cwd_path, cwd_len)
        -- remove trailing path separator
        local full_cwd_path = string.sub(full_cwd_path, 1, cwd_len - 1)
        return vim.fn.pathshorten(full_cwd_path)..path_sep
    end,
    filename = function()
        return vim.fn.fnamemodify(vim.fn.bufname(), ':t')
    end
}

local function highlight_part(part, hl_group)
    return '%#'..hl_group..'#'..part()..'%*'
end

local parts_highlighted = {
    cwd = function()
        local hl_cwd = 'Directory'
        return highlight_part(parts.cwd, hl_cwd)
    end,
    filename = function()
        local modified = vim.api.nvim_buf_get_option(0, 'modified')
        local readonly = vim.api.nvim_buf_get_option(0, 'readonly')
        local hl_filename = modified and 'WarningMsg' or readonly and 'vimSpecFileMod' or 'Normal'
        return highlight_part(parts.filename, hl_filename)
    end
}

local filetype_stl = {
    help = parts_highlighted.filename
}

function stl_module.active()
    local default_stl = parts_highlighted.cwd()..parts_highlighted.filename()
    local filetype = vim.fn.nvim_buf_get_option(0, 'filetype')
    local stl_func = filetype_stl[filetype] or function() return default_stl end
    return stl_func()
end

return stl_module
