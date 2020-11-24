vim.fn = vim.fn or setmetatable({}, {
    __index = function(t, func)
        return function(...)
            return vim.api.nvim_call_function(func, {...})
        end
    end
})

local function build(parts)
    local stl = ''
    for _, part in ipairs(parts) do
        local part_type = type(part)
        local part_result
        if part_type == 'function' then
            part_result = part()
        elseif part_type == 'string' or part_type == 'number' then
            part_result = part
        else
            part_result = ''
        end
        stl = stl .. part_result
    end
    return stl
end

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
    help = {parts_highlighted.filename}
}

function stl_module.active()
    local default_stl = {
        parts_highlighted.cwd,
        parts_highlighted.filename
    }
    local filetype = vim.fn.nvim_buf_get_option(0, 'filetype')
    return build(filetype_stl[filetype] or default_stl)
end

return stl_module
