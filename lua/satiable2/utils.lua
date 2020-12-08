local function tbl_clear(tbl)
    if vim.tbl_count(tbl) > 0 then
        for key in pairs(tbl) do
            rawset(tbl, key, nil)
        end
    end
    return tbl
end

local function update_meta(tbl, meta)
    local tbl_meta = getmetatable(tbl)
    for key, value in pairs(meta) do
        tbl_meta[key] = value
    end
    return setmetatable(tbl, tbl_meta)
end

-- taken from https://www.lua.org/manual/5.2/manual.html#2.4
local function len(arg)
    if type(arg) == 'string' then
        return strlen(arg)
    else
        local len_handler = getmetatable(arg).__len
        if len_handler then
            return len_handler(arg)
        elseif type(arg) == 'table' then
            return #arg
        else
            error(string.format('cannot calculate length of %s', arg))
        end
    end
end

local function tbl_ipairs(tbl)
    local ipairs_handler = getmetatable(tbl).__ipairs
    if ipairs_handler then
        local iter, t, init = ipairs_handler(tbl)
        return iter, t, init
    else
        return ipairs(tbl)
    end
end

return {
    tbl_clear = tbl_clear,
    update_meta = update_meta,
    len = len,
    ipairs = tbl_ipairs,
}
