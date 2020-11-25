return {
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
