local parts = require'config.statusline.parts.highlighted'

local function get_string(value, ...)
    local value_type = type(value)
    if value_type == 'function' then
        return value(...)
    elseif value_type == 'string' or value_type == 'number' then
        return value
    else
        return ''
    end
end

local function build(parts)
    local stl = ''
    for _, part in ipairs(parts) do
        local part_result = get_string(part)
        stl = stl .. part_result
    end
    return stl
end

local filetype_stl = {
    help = {
        parts.filename
    },
}

local function str_split(str, pattern)
    local splitted = {}
    for part in string.gmatch(str, '[^'..pattern..']+') do
        table.insert(splitted, part)
    end
    return splitted
end

local bufname_patterns_stl = {
    ['^term://'] = {
        function(bufname)
            local sep = ':'
            local splitted_term_uri = str_split(bufname, sep)
            local shell_pid = vim.fn.fnamemodify(splitted_term_uri[2], ':t')
            local shell_exec = vim.fn.fnamemodify(splitted_term_uri[#splitted_term_uri], ':t')
            return table.concat({splitted_term_uri[1], shell_pid, shell_exec}, sep)
        end,
    },
}

local function match(patterns_table, str_to_match)
    for pattern, value in ipairs(patterns_table) do
        if string.match(str_to_match, pattern) then
            print('matched '..str_to_match..' to '..pattern)
            return get_string(value, str_to_match)
        end
    end
end

local default_stl = {
    parts.cwd,
    parts.relative_filename,
}

return {
    active = function()
        local filetype = vim.fn.nvim_buf_get_option(0, 'filetype')
        local full_bufname = vim.fn.fnamemodify(vim.fn.bufname(), ':p')
        return build(filetype_stl[filetype] or
                     match(bufname_patterns_stl, full_bufname) or
                     default_stl)
    end,
    inactive = function()
    end,
}
