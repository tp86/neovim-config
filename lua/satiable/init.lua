local function tbl_ipairs(tbl)
    local ipairs_handler = getmetatable(tbl).__ipairs
    if ipairs_handler then
        local iter, t, init = ipairs_handler(tbl)
        return iter, t, init
    else
        return ipairs(tbl)
    end
end
local function tbl_clear(tbl)
    if vim.tbl_count(tbl) > 0 then
        for key in pairs(tbl) do
            rawset(tbl, key, nil)
        end
    end
    return tbl
end

local defaults = {}
defaults.items = {
    -- vim builtin items
    vim_file_path = '%f',
    vim_full_file_path = '%F',
    vim_file_name = '%t',
    vim_modified_brackets = '%m',
    vim_modified_comma = '%M',
    vim_readonly_brackets = '%r',
    vim_readonly_comma = '%R',
    vim_help_brackets = '%h',
    vim_help_comma = '%H',
    vim_preview_brackets = '%w',
    vim_preview_comma = '%W',
    vim_filetype_brackets = '%y',
    vim_filetype_comma = '%Y',
    vim_qf_loc_list = '%q',
    vim_keymap = '%k',
    vim_buffer_number = '%n',
    vim_cursor_char = '%b',
    vim_cursor_char_hex = '%B',
    vim_cursor_offset = '%o',
    vim_cursor_offset_hex = '%O',
    vim_line_number = '%l',
    vim_line_count = '%L',
    vim_column_number = '%c',
    vim_virtual_column_number = '%v',
    vim_virtual_column_number_alt = '%V',
    vim_percentage_lines = '%p',
    vim_percentage_view = '%P',
    vim_args = '%a',
    vim_truncate = '%<',
    vim_align_separator = '%=',
    vim_percent_sign = '%%',
    -- satiable default items
    space = ' ',
    comma = ',',
    cwd_path_sep = function()
        -- for directories, :p adds path separator at the end
        return vim.fn.fnamemodify(vim.fn.getcwd(), ':p')
    end,
    cwd = function()
        -- remove trailing path sep
        return string.sub(defaults.items.cwd_path_sep(), 1, -2)
    end,
    cwd_shortened = function()
        return vim.fn.pathshorten(defaults.items.cwd())
    end,
    bufname = function()
        return vim.fn.bufname()
    end,
    bufname_full = function()
        return vim.fn.fnamemodify(defaults.items.bufname(), ':p')
    end,
    filename = function()
        return vim.fn.fnamemodify(defaults.items.bufname(), ':t')
    end,
    file_path_relative_shortened = function()
        local cwd_escaped = vim.fn.escape(defaults.items.cwd_path_sep(), [[\%]])
        local relative_path = vim.fn.matchstr(defaults.items.bufname_full(), [[\v]]..cwd_escaped..[[\zs.*$]])
        if string.len(relative_path) == 0 then
            relative_path = defaults.items.bufname_full()
        end
        local relative_dir = vim.fn.fnamemodify(relative_path, ':h')
        if relative_dir == '.' then
            return defaults.items.filename()
        end
        return vim.fn.expand(vim.fn.pathshorten(relative_dir)..'/'..defaults.items.filename())
    end
}
defaults.statusline = {
    {
        defaults.items.vim_truncate,
        defaults.items.vim_file_path,
        defaults.items.space,
        defaults.items.vim_help_brackets,
        defaults.items.vim_modified_brackets,
        defaults.items.vim_readonly_brackets,
        defaults.items.vim_align_separator,
        {
            format = '-14.',
            defaults.items.vim_line_number,
            defaults.items.comma,
            defaults.items.vim_column_number,
            defaults.items.vim_virtual_column_number_alt
        },
        defaults.items.space,
        defaults.items.vim_percentage_view,
    }
}
local function is_fulfilled(condition)
    -- TODO proper condition
    return condition == nil or condition()
end
-- add default items names
local items_names = {}
for name, item in pairs(defaults.items) do
    items_names[item] = name
end
local function render_function(item)
    local item_name = items_names[item]
    if item_name then
        return [[%{luaeval("require'satiable'.items.]]..item_name..[[()")}]]
    end
end
local function render_self(item)
    return item
end
local renderer = {
    ['function'] = render_function,
    ['string'] = render_self, --TODO chunk as string
    ['number'] = render_self,
}
local function render_group(group)
    local rendered = {}
    for _, item in ipairs(group) do
        table.insert(rendered, renderer[type(item)](item))
    end
    if #group > 1 then
        table.insert(rendered, 1, '%(')
        table.insert(rendered, '%)')
    end
    rendered = table.concat(rendered, '')
    -- handle format
    local format = group.format or ''
    -- TODO handle case when format is table containing condition and format string
    -- only one case when first character in `rendered` is not '%'
    -- single item being regular string (not vim stl item)
    local first_char = string.sub(rendered, 1, 1)
    if first_char == '%' then
        rendered = '%'..format..string.sub(rendered, 2)
    elseif #format > 0 then
        -- surround regular string in group only when there is format
        rendered = '%'..format..'('..rendered..'%)'
    end
    -- TODO apply highlighting if exists
    -- handle condition and multiple possible highlight groups
    return rendered
end
renderer['table'] = render_group
local function render_statusline_config(stl_config_tbl)
    -- TODO caching items calls
    local rendered = {}
    for _, item in ipairs(stl_config_tbl) do
        table.insert(rendered, renderer[type(item)](item))
    end
    return table.concat(rendered, '')
end
local function render_statusline(stl_tbl)
    for _, stl_config_tbl in tbl_ipairs(stl_tbl) do
        local condition = stl_config_tbl.condition
        if is_fulfilled(condition) then
            return render_statusline_config(stl_config_tbl)
        end
    end
end
local statusline_meta = {}
local function configure_table(tbl, t)
    if type(t) == 'table' then
        tbl = tbl_clear(tbl)
        for k, v in pairs(t) do
            tbl[k] = v
        end
    end
end
statusline_meta.__call = function(stl_tbl, tbl)
    if tbl == nil then
        return render_statusline(stl_tbl)
    else
        configure_table(stl_tbl, tbl)
    end
end
statusline_meta.__index = function(stl_tbl, index)
    local value = rawget(stl_tbl, index)
    if value == nil then
        value = defaults.statusline[index - #stl_tbl]
    end
    return value
end
statusline_meta.__ipairs = function(stl_tbl)
    local function iter(tbl, index)
        index = index + 1
        local value = tbl[index]
        if value ~= nil then
            return index, value
        end
    end
    return iter, stl_tbl, 0
end
local statusline = {}
setmetatable(statusline, statusline_meta)
local items_meta = {
    __call = configure_table,
    __index = defaults.items,
    __newindex = function(tbl, key, value)
        items_names[value] = key
        rawset(tbl, key, value)
    end,
}
local items = {}
setmetatable(items, items_meta)
local m = {
    statusline = statusline,
    items = items,
}

return m
