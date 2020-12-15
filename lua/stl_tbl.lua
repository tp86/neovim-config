local m = {}
local function make_hl_func(hl_def, f)
    return function()
        if hl_def.when() then
            return f()
        end
        return ''
    end
end
local function add_hl_item(hl_tbl, hl_group)
    table.insert(hl_tbl, '%#'..hl_group..'#')
end
local function add_hl_func(hl_tbl, f_name)
    table.insert(hl_tbl, [[%{luaeval("require'stl_tbl'.items.]]..f_name..[[()")}]])
end
local converters = {
    function(item, f) -- conditional
        if item.when then
            return function()
                if item.when() then
                    return f()
                end
                return ''
            end
        end
        return f
    end,
    function(item, f, item_index) -- highlights
        if item.highlight then
            local highlights = {}
            if type(item.highlight) == 'table' then
                for i, hl_def in ipairs(item.highlight) do
                    add_hl_item(highlights, hl_def[1])
                    local func_name = '_'..item_index..'_'..i
                    m.items[func_name] = make_hl_func(hl_def, f)
                    add_hl_func(highlights, func_name)
                end
            elseif type(item.highlight) == 'string' then
                add_hl_item(highlights, item.highlight)
                local func_name = '_'..item_index..'_' .. 0
                m.items[func_name] = function() return f() end
                add_hl_func(highlights, func_name)
            end
            table.insert(highlights, '%*')
            return table.concat(highlights, '')
        end
        return f()
    end,
    -- TODO add format
}
local function lookup_func_name(tbl, func)
    for name, value in pairs(tbl) do
        if value == func then
            return name
        end
    end
end
local item_type_dispatcher = {
    ['table'] = function(item, item_index)
        local group_func = function()
            local group = {}
            for _, item in ipairs(item) do
                if type(item) == 'string' then
                    table.insert(group, item)
                elseif type(item) == 'function' then
                    table.insert(group, item())
                end
            end
            return table.concat(group, '')
        end
        local value = group_func
        for _, converter in ipairs(converters) do
            value = converter(item, value, item_index)
        end
        return value
    end,
    ['string'] = function(item)
        return item
    end,
    ['function'] = function(item)
        local func_name = lookup_func_name(m.items, item)
        return [[%{luaeval("require'stl_tbl'.items.]]..func_name..[[()")}]]
    end
}
local function converter(item, item_index)
    return item_type_dispatcher[type(item)](item, item_index)
end

local conditions = {}
conditions.active = function()
    return vim.api.nvim_get_var('actual_curwin') == string.format('%d', vim.fn.win_getid())
end
conditions.inactive = function()
    return not conditions.active()
end
conditions.mod = function()
    return vim.api.nvim_buf_get_option(0, 'modified')
end
conditions.nomod = function()
    return not conditions.mod()
end
conditions.ro = function()
    return vim.api.nvim_buf_get_option(0, 'readonly')
end
conditions.noro = function()
    return not vim.api.nvim_buf_get_option(0, 'readonly')
end
conditions.mod_active = function()
    return conditions.active() and conditions.mod()
end
conditions.mod_inactive = function()
    return conditions.inactive() and conditions.mod()
end
conditions.ro_active = function()
    return conditions.active() and conditions.nomod() and conditions.ro()
end

conditions.ro_inactive = function()
    return conditions.inactive() and conditions.nomod() and conditions.ro()
end
conditions.fname_active = function()
    return conditions.active() and conditions.nomod() and conditions.noro()
end
conditions.fname_inactive = function()
    return conditions.inactive() and conditions.nomod() and conditions.noro()
end
m.items = {
    bufname = function()
        return vim.fn.bufname()
    end,
    bufname_full = function()
        return vim.fn.fnamemodify(m.items.bufname(), ':p')
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
        local full_cwd = vim.fn.escape(vim.fn.fnamemodify(m.items.cwd(), ':p'), [[\%]])
        local relative_path = vim.fn.matchstr(m.items.bufname_full(), [[\v]]..full_cwd..[[\zs.*$]])
        if #relative_path == 0 then
            relative_path = m.items.bufname_full()
        end
        local relative_dir = vim.fn.fnamemodify(relative_path, ':h')
        if relative_dir == '.' then
            return m.items.filename()
        else
            return vim.fn.expand(vim.fn.pathshorten(relative_dir)..'/'..m.items.filename())
        end
    end
}
local statusline = {
    {
        when = conditions.active,
        highlight = 'StlCwd',
        m.items.cwd_shortened,
        ': ',
    },
    {
        highlight = {
            { when = conditions.mod_active, 'StlFnameMod' },
            { when = conditions.mod_inactive, 'StlNCFnameMod' },
            { when = conditions.ro_active, 'StlFnameRo' },
            { when = conditions.ro_inactive, 'StlNCFnameRo' },
            { when = conditions.fname_active, 'StlFname' },
            { when = conditions.fname_inactive, 'StlNCFname' },

        },
        m.items.file_path_relative
    },
    '%=',
    '%l(%L):%-3c',
}

m.statusline = setmetatable(statusline, {
    __call = function(tbl)
        local items = {}
        for i, item in ipairs(tbl) do
            table.insert(items, converter(item, i))
        end
        return table.concat(items, '')
    end
})
return m
