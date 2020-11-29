local defaults = {
    components = {},
    statusline = {},
}

local function transform_set(tbl, transformer)
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
        __newindex = transform_set(components),
        __index = cache(components),
        __metatable = nil
    })
end

local components = new_components()

local m = setmetatable({}, {
    __index = function(_, k)
        if k == "components" then
            return components
        end
    end,
    __newindex = function(_, k, v)
        if k == "components" then
            components = new_components()
            for ck, cv in pairs(v) do
                components[ck] = cv
            end
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


print(m.components.b)
print(m.components.a)
m.components = {
    b = 3
}
print(m.components.b)
print(m.components.a)
print(m.components.bufname)
print(m.components.filename)
