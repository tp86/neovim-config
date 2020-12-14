local m = {}
m.items = {
    filename = function()
        return vim.fn.fnamemodify(m.items.bufname(), ':t')
    end,
    bufname = function()
        return vim.fn.bufname()
    end,
}
local conditional_item = {
    when = function()
        return vim.fn.fnamemodify(m.items.bufname(), ':h') == 'lua'
    end,
    m.items.filename
}
local function convert_conditional_item(item, f)
    if item.when then
        return function()
            if item.when() then
                return item[1]()
            end
            return ''
        end
    end
    return f
end
local highlighted_item = {
    highlight = {
        {
            when = function()
                return vim.api.nvim_buf_get_option(0, 'modified')
            end,
            'WarningMsg'
        },
        {
            when = function()
                return not vim.api.nvim_buf_get_option(0, 'modified')
            end,
            'String'
        },
    },
    m.items.filename
}
local function convert_highlighted_item(item, f)
    if item.highlight then
        local highlights = {}
        for i, hl_tbl in ipairs(item.highlight) do
            table.insert(highlights, '%#'..hl_tbl[1]..'#')
            local hl_func = function()
                if hl_tbl.when() then -- TODO handle unconditional highlight
                    return f()
                end
                return ''
            end
            m.items['hl'..i] = hl_func
            table.insert(highlights, 'luaeval require...items.hl'..i)
        end
        return table.concat(highlights, '')
    end
    return f()
end
m.ci = convert_conditional_item(conditional_item, conditional_item[1])
m.hi = convert_highlighted_item(highlighted_item, highlighted_item[1])
local function converter(item)
    local func = item[1]
    local converters = {
        convert_conditional_item,
        convert_highlighted_item,
    }
    local value = func
    for _, converter in ipairs(converters) do
        value = converter(item, value)
    end
    return value
end
local cond_hl_item = {
    when = function()
        return vim.fn.fnamemodify(m.items.bufname(), ':h') == 'lua'
    end,
    highlight = {
        {
            when = function()
                return vim.api.nvim_buf_get_option(0, 'modified')
            end,
            'WarningMsg'
        },
        {
            when = function()
                return not vim.api.nvim_buf_get_option(0, 'modified')
            end,
            'String'
        },
    },
    m.items.filename
}
m.c = converter(cond_hl_item)
return m
