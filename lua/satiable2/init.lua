local dynamic_access_table = require'satiable2.dynamic_access_table'
local tbl_clear = require'satiable2.utils'.tbl_clear
local update_meta = require'satiable2.utils'.update_meta

local defaults = {
    items = {
        file_path = '%f',
        full_file_path = '%F',
        file_name = '%t',
        modified_brackets = '%m',
        modified_comma = '%M',
        readonly_brackets = '%r',
        readonly_comma = '%R',
        help_brackets = '%h',
        help_comma = '%H',
        preview_brackets = '%w',
        preview_comma = '%W',
        filetype_brackets = '%y',
        filetype_comma = '%Y',
        qf_loc_list = '%q',
        keymap = '%k',
        buffer_number = '%n',
        cursor_char = '%b',
        cursor_char_hex = '%B',
        cursor_offset = '%o',
        cursor_offset_hex = '%O',
        line_number = '%l',
        line_count = '%L',
        column_number = '%c',
        virtual_column_number = '%v',
        virtual_column_number_alt = '%V',
        percentage_lines = '%p',
        percentage_view = '%P',
        args = '%a',
        truncate = '%<',
        align_separator = '%=',
        percent_sign = '%%',
    }
}
local items_defaults_meta = {
    __index = defaults.items
}

local items = setmetatable({}, items_defaults_meta)
local statusline = {}

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
    items = {
        index = function()
            return items
        end,
        newindex = function(new_items)
            items = tbl_clear(items)
            if new_items and vim.tbl_count(new_items) > 0 then
                for key, value in pairs(new_items) do
                    items[key] = value
                end
            end
        end,
    },
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
local stl = dynamic_access_table({}, statusline_dat)

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
    for _, stl_table in ipairs(statusline) do
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
return dynamic_access_table({}, m)
