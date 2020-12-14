local items = {
    -- vim builtins
    vim = {
        file = {
            path = '%f',
            full_path = '%F',
            name = '%t',
        },
        modified = {
            brackets = '%m',
            comma = '%M',
        },
        readonly = {
            brackets = '%r',
            comma = '%R',
        },
        help = {
            brackets = '%h',
            comma = '%H',
        },
        preview = {
            brackets = '%w',
            comma = '%W',
        },
        filetype = {
            brackets = '%y',
            comma = '%Y',
        },
        qf_loc_list = '%q',
        keymap = '%k',
        buffer_number = '%n',
        cursor = {
            char = '%b',
            char_hex = '%B',
            byte_number = '%o',
            byte_number_hex = '%O',
        },
        line_number = '%l',
        line_count = '%L',
        column = {
            number = '%c',
            virtual = '%v',
            virtual_alt = '%V',
        },
        percentage = {
            lines = '%p',
            view = '%P',
        },
        args = '%a',
        tbl = {
            page_start = '%T',
            close_start = '%X',
        },
        truncate = '%<',
        alignment_separator = '%=',
    },
    chars = {
        space = ' ',
        percent = '%%',
        comma = ',',
        colon = ':',
    },
    cwd = function()
        return vim.fn.getcwd()
    end,
}
local conditions = {
    active_window = function()
        return string.format('%d', vim.fn.win_getid()) == vim.api.nvim_get_var('actual_curwin')
    end
}

local statusline_configs = {
    items = items,
    {
        when = conditions.active_window,
        items.cwd
    },
    { -- default configuration
        --when = always
        --{
            --when = always
            --highlight = {
            --  {
            --      when = --some condition
            --      'WarningMsg' -- some hlgroup
            --  },
            --  ...
            --}
            --items in group
        --}
        items.vim.truncate, -- group with one item, when and highlight are nil
        items.vim.file.path,
        items.chars.space,
        items.vim.help.brackets,
        items.vim.modified.brackets,
        items.vim.readonly.brackets,
        items.vim.alignment_separator,
        {
            format = '-14.',
            items.vim.line_number,
            items.chars.comma,
            items.vim.column.number,
            items.vim.column.virtual_alt,
        },
        items.chars.space,
        items.vim.percentage.view,
    }
}

local renderer = {}
renderer.get_renderer = function(self, item)
    local renderers = {
        ['string'] = self.render_self,
        ['number'] = self.render_self,
        ['function'] = self.render_expression,
        ['table'] = self.render_group,
    }
    return renderers[type(item)]
end
renderer.render = function(self, item, item_index, config_index)
    return self.get_renderer(self, item)(self, item, item_index, config_index)
end

renderer.render_self = function(self, item)
    return item
end
renderer.render_group = function(self, group)
    local single_item_in_group = #group == 1
    local rendered = {}
    if not single_item_in_group then
        -- multiple items in group need to be surrounded by %(, %)
        table.insert(rendered, '%(')
        for item_index, item in ipairs(group) do
            table.insert(rendered, self:render(item))
        end
        table.insert(rendered, '%)')
    else
        -- single item renders normally
        table.insert(rendered, self:render(group[1]))
    end
    rendered = table.concat(rendered, '')
    -- apply format if exists
    local format = group.format or ''
    -- if string does not begin with '%', it is a single plain string
    local is_simple_string = string.sub(rendered, 1, 1) ~= '%'
    if is_simple_string then
        -- it must be surrounded in group to apply formatting
        rendered = '%'..format..'('..string.sub(rendered, 2)..'%)'
    else
        -- format to item/group can be applied directly
        rendered = '%'..format..string.sub(rendered, 2)
    end
    -- apply highlighting
    return rendered
end
renderer.render_expression = function(self, item, item_index, config_index)
    -- try to lookup item function name in items
    local item_name = nil
    for name, func in pairs(items) do
        if type(func) == 'function' then
            if item == func then
                item_name = name
                break
            end
        end
    end
    local expr_header = [[%{luaeval("require'stl_tbl'.statusline]]
    local expr_footer = [[()")}]]
    if item_name then
        return expr_header..'.items.'..item_name..expr_footer
    else
        return expr_header..'['..config_index..']['..item_index..']'..expr_footer
    end
end



local function lookup_func_name(func_tbl, func)
    for name, func_value in pairs(func_tbl) do
        if func == func_value then
            return name
        end
    end
end

local compiled_statusline_configs = {}
local function statusline()
    local rendered = {}
    for config_index, config in ipairs(statusline_configs) do
        local config_func = {}
        table.insert(config_func, [[local conditions = require'stl_tbl'.conditions]])
        table.insert(config_func, [[local items = require'stl_tbl'.items]])
        local condition = config.when
        if condition then
            table.insert(config_func, [[if conditions.]]..lookup_func_name(conditions, condition)..[[() then]])
        end
        table.insert(config_func, [[local result = '']])
        for item_index, item in ipairs(config) do
            table.insert(config_func, [[result = result..items.]]..lookup_func_name(items, item)..[[()]])
            --table.insert(config_func, renderer:render(item, item_index, config_index))
        end
        table.insert(config_func, [[return result]])
        if condition then
            table.insert(config_func, [[end]])
        end
        table.insert(compiled_statusline_configs, loadstring(table.concat(config_func, ' ')))
        table.insert(rendered, [[%{luaeval("require'stl_tbl'.statusline]]..'['..config_index..']'..[[()")}]])
        break
    end
    return table.concat(rendered, '')
end

return {
    statusline = setmetatable(compiled_statusline_configs, { __call = statusline }),
    conditions = conditions,
    items = items,
}
