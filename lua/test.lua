local defaults = {
    components = {},
    statusline = {},
}

local function transform_write(tbl, transformer)
    return function(_, k, v)
        if transformer then
            v = transformer(v)
        end
        rawset(tbl, k, v)
    end
end

local function cache(tbl)
    local cache_table = {}
    return setmetatable(cache_table, {
        __index = function(t, k)
            local tbl_value = tbl[k]
            local callable, result = pcall(tbl_value)
            if callable then
                tbl_value = result
            end
            rawset(t, k, tbl_value)
            return rawget(t, k)
        end
    })
end

local function new_components()
    local components = setmetatable({}, {
        __index = defaults.components
    })
    return setmetatable({}, {
        __newindex = transform_write(components),
        __index = cache(components),
        __metatable = nil
    })
end

local function new_statusline()
    return setmetatable({}, {
        __index = function(t, k)
            if rawget(t, k) == nil then
                return defaults.statusline[k - #t]
            end
        end,
        __call = function(t)
            for i = 1, #t + #defaults.statusline do
                local v = t[i]
                if v == nil then
                    break
                end
                local condition = v.condition
                local callable, result = pcall(condition)
                if condition == nil or callable and result or condition then
                    -- TODO actual rendering function
                    print('rendering statusline number '..i)
                    print(vim.inspect(v))
                    return v[#v]
                end
            end
        end,
    })
end

local components = new_components()
local statusline = new_statusline()

local m_index = {
    components = function()
        return components
    end,
    statusline = function()
        return statusline
    end,
}

local m_newindex = {
    components = function(new_table)
        components = new_components()
        for k, v in pairs(new_table) do
            components[k] = v
        end
    end,
    statusline = function(new_table)
        statusline = new_statusline()
        for k, v in ipairs(new_table) do
            statusline[k] = v
        end
    end,
}

local m = setmetatable({}, {
    __index = function(_, k)
        local func = m_index[k]
        if func then
            return func()
        end
    end,
    __newindex = function(_, k, v)
        local func = m_newindex[k]
        if func then
            func(v)
        end
    end,
    __metatable = nil
})

defaults.components.bufname = function()
    print("called bufname")
    return vim.fn.bufname()
end
defaults.components.filename = function()
    print("called filename")
    return vim.fn.fnamemodify(m.components.bufname, ":t")
end
defaults.statusline = {
    {
        condition = false
    },
    {
        defaults.components.bufname
    }
}

-- user config

m.components = {
    a = function()
        print("called a")
        return 5
    end,
    b = function()
        print("called b")
        return vim.fn.fnamemodify(m.components.bufname, ":h")
    end
}

-- usage

print(m.components.b)
print(m.components.a)
m.components = {
    b = 3
}
print(m.components.b)
print(m.components.a)
print(m.components.bufname)
print(m.components.bufname)
print(m.components.filename)

m.components.c = m.components.bufname

m.statusline = {
    {
        condition = false,
        m.components.filename
    },
    {
        m.components.b,
        m.components.c
    }
}

m.statusline()
return m
