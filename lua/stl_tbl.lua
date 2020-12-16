-- TODO cache m.items
local m = {}
local conditions = {}
conditions.active = function()
    return vim.api.nvim_get_var('actual_curwin') == string.format('%d', vim.fn.win_getid())
end
conditions.mod = function()
    return vim.api.nvim_buf_get_option(0, 'modified')
end
conditions.ro = function()
    return vim.api.nvim_buf_get_option(0, 'readonly')
end
conditions.term_buffer = function()
    return vim.fn.match(m.items.bufname_full(), [[\v^term://]]) == 0
end
conditions.no_file = function()
    return #m.items.bufname() == 0
end
m.items = {
    bufname = function()
        return vim.fn.bufname()
    end,
    bufname_full = function()
        return vim.fn.fnamemodify(m.items.bufname(), ':p')
    end,
    empty_file = function()
        return '[No Name]'
    end,
    filename = function()
        return vim.fn.fnamemodify(m.items.bufname(), ':t')
    end,
    cwd = function()
        return vim.fn.fnamemodify(vim.fn.getcwd(), ':~')
    end,
    cwd_shortened = function()
        return vim.fn.pathshorten(m.items.cwd())
    end,
    file_path_relative = function()
        local full_cwd = vim.fn.escape(vim.fn.fnamemodify(vim.fn.getcwd(), ':p'), [[\%]])
        local relative_path = vim.fn.matchstr(m.items.bufname_full(), [[\v^]]..full_cwd..[[\zs.*$]])
        if #relative_path == 0 then
            relative_path = m.items.bufname_full()
        end
        local relative_dir = vim.fn.fnamemodify(relative_path, ':h')
        if relative_dir == '.' then
            return m.items.filename()
        else
            return vim.fn.expand(vim.fn.pathshorten(relative_dir)..'/'..m.items.filename())
        end
    end,
    term = function()
        local splitted_uri = vim.fn.split(m.items.bufname_full(), ':')
        local shell_pid = vim.fn.fnamemodify(splitted_uri[2], ':t')
        local shell_exec = vim.fn.fnamemodify(splitted_uri[#splitted_uri], ':t')
        return table.concat({splitted_uri[1], shell_pid, shell_exec}, ':')
    end,
}
local items = {}
items.cwd = function()
    return vim.fn.fnamemodify(vim.fn.getcwd(), ':~')
end
items.cwd_shortened = function()
    return vim.fn.pathshorten(items.cwd())
end
items.bufname_full = function()
    return vim.fn.fnamemodify(vim.fn.bufname(), ':p')
end
items.file_path_relative = function()
    local full_cwd = vim.fn.escape(vim.fn.fnamemodify(vim.fn.getcwd(), ':p'), [[\%]])
    local relative_path = vim.fn.matchstr(items.bufname_full(), [[\v^]]..full_cwd..[[\zs.*$]])
    if #relative_path == 0 then
        relative_path = items.bufname_full()
    end
    local relative_dir = vim.fn.fnamemodify(relative_path, ':h')
    local filename = vim.fn.fnamemodify(items.bufname_full(), ':t')
    if relative_dir == '.' then
        return filename
    else
        return vim.fn.expand(vim.fn.pathshorten(relative_dir)..'/'..filename)
    end
end

local conditions = {}
conditions.active = function()
    return vim.api.nvim_get_var('actual_curwin') == string.format('%d', vim.fn.win_getid())
end
conditions.mod = function()
    return vim.api.nvim_buf_get_option(0, 'modified')
end
conditions.ro = function()
    return vim.api.nvim_buf_get_option(0, 'readonly')
end
conditions.term_buffer = function()
    return vim.fn.match(items.bufname_full(), [[\v^term://]]) == 0
end
conditions.special = function()
    return conditions.term_buffer()
end
conditions.empty_file = function()
    return #vim.fn.bufname() == 0
end
local filename_conditions = {
    [1] = function()
        return conditions.active()
        and not conditions.empty_file()
        and not conditions.special()
        and not conditions.mod()
        and not conditions.ro()
    end,
    [2] = function()
        return conditions.active()
        and not conditions.empty_file()
        and not conditions.special()
        and conditions.mod()
    end,
    [3] = function()
        return conditions.active()
        and not conditions.empty_file()
        and not conditions.special()
        and not conditions.mod()
        and conditions.ro()
    end,
    [4] = function()
        return not conditions.active()
        and not conditions.empty_file()
        and not conditions.special()
        and not conditions.mod()
        and not conditions.ro()
    end,
    [5] = function()
        return not conditions.active()
        and not conditions.empty_file()
        and not conditions.special()
        and conditions.mod()
    end,
    [6] = function()
        return not conditions.active()
        and not conditions.empty_file()
        and not conditions.special()
        and not conditions.mod()
        and conditions.ro()
    end,
}
return {
    statusline = table.concat{
        -- cwd part visible only in active window
        [[%#StlCwd#%{luaeval("require'stl_tbl'.items.cwd()")}]],
        [[%*]],
        -- filename part with conditional highlighting and conditional visibility
        [[%#StlFname#%{luaeval("require'stl_tbl'.items.filename(1)")}]],
        [[%#StlFnameMod#%{luaeval("require'stl_tbl'.items.filename(2)")}]],
        [[%#StlFnameRo#%{luaeval("require'stl_tbl'.items.filename(3)")}]],
        [[%#StlNCFname#%{luaeval("require'stl_tbl'.items.filename(4)")}]],
        [[%#StlNCFnameMod#%{luaeval("require'stl_tbl'.items.filename(5)")}]],
        [[%#StlNCFnameRo#%{luaeval("require'stl_tbl'.items.filename(6)")}]],
        [[%*]],
        '%=',
        '(%{pathshorten(FugitiveHead(8))})',
        ' ',
        '$[%.10(%{xolox#session#find_current_session()}%)]'
    },
    items = {
        cwd = function()
            if conditions.active() then
                return items.cwd_shortened()..': '
            end
            return ''
        end,
        filename = function(cond)
            if filename_conditions[cond]() then
                return items.file_path_relative()
            end
            return ''
        end,
    },
}
