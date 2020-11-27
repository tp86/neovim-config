local cache = require"cacher"

local components = {}

local function transform_set(tbl, transformer)
    return function(_, k, v)
        if transformer then
            v = transformer(v)
        end
        rawset(tbl, k, v)
    end
end

local function table_w_transform_r_cache(tbl)
    return {
        __newindex = transform_set(tbl),
        __index = cache(tbl),
    }
end

local m = {
    components = setmetatable({}, table_w_transform_r_cache(components))
}

m.components.a = function()
    print("called a")
    return 5
end

m.components.b = function()
    print("called b")
    return m.components.a + 3
end


print(m.components.b)
print(m.components.b)
print(m.components.a)
