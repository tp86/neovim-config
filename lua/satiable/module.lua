local items_names = {}

local items = setmetatable({}, {
    -- TODO add defaults
    __newindex = function(tbl, key, val)
        items_names[key] = key
        rawset(tbl, key, val)
    end,
})

local function cache(tbl)
    local cache_table = {}
    return setmetatable(cache_table, {
        __index = function(t, key)
            local value = tbl[key]()
            rawset(t, key, value)
            return rawget(t, key)
        end,
        -- don't write to cache directly
        -- instead pass to cached table
        __newindex = tbl,
    })
end

local cached_items = cache(items)

local function build_stl(stl_tbl)
    local stl = ''
    print(vim.inspect(stl_tbl))
    for _, item in ipairs(stl_tbl) do
        local item_name = item
        stl = stl .. [[%{luaeval("require'satiable.module'.items.]]..item_name..'")}'
    end
    return stl
end

local statusline = {}

local m = {
    newindex = {
        items = function(new_value)
            for key, val in pairs(new_value) do
                -- TODO convert val into function
                items[key] = val
            end
        end,
        statusline = function(new_table)
            for i, stl_tbl in ipairs(new_table) do
                statusline[i] = stl_tbl
            end
        end,
    },
    index = {
        items = function()
            return items
        end,
        statusline = function()
            return statusline
        end,
    },
}

setmetatable(statusline, {
    -- TODO add defaults
    __call = function(statuslines_tbl)
        for i = 1, #statuslines_tbl do
            -- TODO add condition
            --print('statusline')
            local stl_tbl = statuslines_tbl[i]
            -- change m.index.items to return name from (local) items
            m.index.items = function()
                return items_names
            end
            print(vim.inspect(require'satiable.module'.items))
            print(vim.inspect(require'satiable.module'.items.bufname))
            local stl = build_stl(stl_tbl)
            print(stl)
            -- change m.index.items to return cached_items
            cached_items = cache(items)
            m.index.items = function()
                return cached_items
            end
            return '%f'
        end
    end,
})

local m_meta = {
    __newindex = function(_, field, new_value)
        local field_func = m.newindex[field]
        if field_func then field_func(new_value) end
    end,
    __index = function(_, field)
        local field_func = m.index[field]
        if field_func then return field_func() end
    end,
}

return setmetatable({}, m_meta)
