local dat = require'satiable2.dynamic_access_table'
local tbl_clear = require'satiable2.utils'.tbl_clear
local update_meta = require'satiable2.utils'.update_meta
local utils = require'satiable2.utils'

local defaults = {
    statusline = {}
}
local default_items = {}
local defaults_dat = {
    items = dat.access_during_assignment(default_items),
}
defaults = dat.dynamic_access_table(defaults, defaults_dat)
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
local items_defaults_meta = {
    __index = defaults.items
}
defaults.statusline = {
    {
        defaults.items.vim_truncate,
        defaults.items.vim_file_path,
        ' ',
        defaults.items.vim_help_brackets,
        defaults.items.vim_modified_brackets,
        defaults.items.vim_readonly_brackets,
        defaults.items.vim_align_separator,
        '%-14.(',
        -- TODO:
        --  {
        --      format = '-14.',
        --      defaults.items.vim_line_number,
        --      ',',
        --      defaults.items.vim_column_number,
        --      defaults.items.vim_virtual_column_number_alt
        --  }
        defaults.items.vim_line_number,
        ',',
        defaults.items.vim_column_number,
        defaults.items.vim_virtual_column_number_alt,
        '%)',
        ' ',
        -- defaults.items.space
        defaults.items.vim_percentage_view,
    }
}

local items = setmetatable({}, items_defaults_meta)
local statusline = setmetatable({}, {
    __ipairs = function(tbl)
        local function iter(t, i)
            i = i + 1
            local v = t[i]
            if v ~= nil then
                return i, v
            else
                return i, defaults.statusline[i - #t]
            end
        end
        return iter, tbl, 0
    end
})

local function add_stl_tbl(index, value)
    -- allow adding number-indexed tables (only) to statusline
    if type(value) == 'table' then
        statusline[index] = value
        return
    end
    error('statusline configuration must be a table')
end
local number_index_dat = function(index)
    return {
        -- should have newindex field returning function accepting one argument - new value
        -- this has to be a closure over `index`
        newindex = function(value)
            return add_stl_tbl(index, value)
        end,
        index = function()
            return statusline[index]
        end,
    }
end

local statusline_dat = {
    items = dat.access_during_assignment(items),
}
-- index that is not found in `statusline_dat` and is a number should be added directly to `statusline`
local statusline_dat_meta = {
    -- indexing key not found in original dat table
    __index = function(_, index)
        if type(index) == 'number' then
            -- inherit number-indexing from returned table
            return number_index_dat(index)
        end
    end
}
setmetatable(statusline_dat, statusline_dat_meta)
local stl = dat.dynamic_access_table({}, statusline_dat)

local function lookup_func_name(item)
    for name, func in pairs(items) do
        if func == item then
            return name
        end
    end
    return nil
end
local function render_function(item)
    local name = lookup_func_name(item)
    if name then
        return [[%{luaeval("require'satiable'.statusline.items.]]..name..[[()")}]]
    end
end
local function render_simple(item)
    return item
end
local renderers = {
    ['function'] = render_function,
    ['string'] = render_simple,
    ['number'] = render_simple,
}
local function render_statusline(stl_tbl)
    local rendered_items = {}
    for _, item in ipairs(stl_tbl) do
        table.insert(rendered_items, renderers[type(item)](item))
    end
    return table.concat(rendered_items, '')
end
local build_statusline = function()
    for _, stl_table in utils.ipairs(statusline) do
        return render_statusline(stl_table)
    end
end

stl = update_meta(stl, {
    __call = build_statusline,
    __len = function()
        return #statusline
    end,
})

local m = {
    statusline = {
        index = function()
            return stl
        end,
        newindex = function(new_statusline_tbl)
            statusline = tbl_clear(statusline)
            if new_statusline_tbl and vim.tbl_count(new_statusline_tbl) > 0 then
                for key, value in pairs(new_statusline_tbl) do
                    statusline[key] = value
                end
            end
        end
    },
}
return dat.dynamic_access_table({}, m)
