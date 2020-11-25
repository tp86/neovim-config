local function full_cwd_path()
    return vim.fn.fnamemodify(vim.fn.getcwd(), ':p')
end

local function get_path_sep()
    local full_cwd_path = full_cwd_path()
    local cwd_len = string.len(full_cwd_path)
    return string.sub(full_cwd_path, cwd_len)
end
local path_sep = get_path_sep()

return {
    cwd = function()
        local full_cwd_path = full_cwd_path()
        local cwd_len = string.len(full_cwd_path)
        -- remove trailing path separator
        -- this is to avoid shortening last path segment
        full_cwd_path = string.sub(full_cwd_path, 1, cwd_len - 1)
        return vim.fn.pathshorten(full_cwd_path)..path_sep
    end,
    filename = function()
        return vim.fn.fnamemodify(vim.fn.bufname(), ':t')
    end,
    relative_filename = function()
        local bufname = vim.fn.bufname()
        if string.len(bufname) == 0 then
            return ''
        end
        local full_bufname = vim.fn.fnamemodify(bufname, ':p')
        local full_cwd_path = full_cwd_path()
        full_cwd_path = vim.fn.escape(full_cwd_path, '\\%')
        local relative_path = vim.fn.matchstr(full_bufname, '\\v'..full_cwd_path..'\\zs.*$')
        if string.len(relative_path) == 0 then
            relative_path = full_bufname
        end
        local relative_dir = vim.fn.fnamemodify(relative_path, ':h')
        local filename = vim.fn.fnamemodify(bufname, ':t')
        if relative_dir == '.' then
            return filename
        else
            relative_dir = vim.fn.pathshorten(relative_dir)
            return table.concat({relative_dir, filename}, path_sep)
        end
    end,
}
