-- TODO defaults
local function identity(value)
    return value
end
local conversions = {
    ['function'] = identity,
    ['string'] = identity -- TODO
}
local function convert(value)
    local conversion_func = conversions[type(value)]
    return conversion_func(value)
end
local parts_meta = {
    __newindex = function(t, k, v)
        -- TODO convert v
        -- function -> function (no conversion)
        -- string
        --      valid chunk -> function
        --      else -> string (no conversion)
        local converted = convert(v)
        rawset(t, k, converted)
    end
}
local cached_parts = {}
local cached_parts_names = setmetatable({}, {__mode = 'k'})
local cache = function(tbl)
    local cache_table = {}
    local cache_meta = {
        __index = function(t, key)
            local value = tbl[key]
            if type(value) == 'function' then
                local ret_value = value()
                value = function()
                    return ret_value
                end
            end
            rawset(t, key, value)
            rawset(cached_parts_names, value, key)
            return value
        end,
        __newindex = tbl
    }
    setmetatable(cache_table, cache_meta)
    return cache_table
end
local function new_parts()
    local parts = {}
    setmetatable(parts, parts_meta)
    cached_parts = cache(parts)
    return parts
end
local parts = new_parts()
--local statusline_built = {}
local function build_statusline_part(part_name)
    -- TODO multiple statuslines (with defaults as last)
    -- TODO strings in statusline
    -- TODO conditions
    -- TODO highlights (conditional)
    -- TODO grouping
    -- TODO item width and justification
    local part_type = type(cached_parts[part_name])
    if part_type == 'function' then
        return [[%{luaeval("require'satiable'.parts.]]..part_name..'()")}'
    end
    return cached_parts[part_name]
end
local function new_statusline()
    local statusline = {}
    return setmetatable(statusline, {
        __newindex = function(t, k, v)
            --rawset(statusline_built, k, build_statusline_part(cached_parts_names[v]))
            rawset(t, k, v)
        end,
        __call = function(t)
            cached_parts = cache(parts)
            local statusline_built = {}
            for _, statusline_part in ipairs(t) do
                table.insert(statusline_built, build_statusline_part(cached_parts_names[statusline_part]))
            end
            local statusline = table.concat(statusline_built, '')
            collectgarbage()
            return statusline
        end
    })
end
local statusline = new_statusline()

local m = {
    parts = {
        getter = function()
            return cached_parts
        end,
        setter = function(new_value)
            parts = new_parts()
            cached_parts = cache(parts)
            for key, value in pairs(new_value) do
                parts[key] = value
            end
        end,
    },
    statusline = {
        getter = function()
            return statusline
        end,
        setter = function(new_value)
            statusline = new_statusline()
            for i, value in ipairs(new_value) do
                statusline[i] = value
            end
        end
    },
    cached_parts_names = {
        getter = function()
            return cached_parts_names
        end
    }
}
local m_meta = {
    __index = function(_, field)
        local field_getter = m[field].getter
        if field_getter then
            return field_getter()
        end
    end,
    __newindex = function(_, field, value)
        local field_setter = m[field].setter
        if field_setter then return field_setter(value) end
    end,
    __metatable = nil
}
return setmetatable({}, m_meta)
