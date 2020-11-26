local function trim(str)
    str = string.gsub(str, '^%s+', '')
    str = string.gsub(str, '%s+$', '')
    return str
end

local function escape(str, chars, levels)
    local escapes = string.rep('\\', levels or 1)
    for c in string.gmatch(chars, '.') do
        str = string.gsub(str, c, escapes..c)
    end
    return str
end

-------------------------------------------------------------

local parts = {}

local satiable = {
    parts = parts
}

local function build(parts)
    local result = {}
    for _, part in pairs(parts) do
        if loadstring(part) then
            local processed_part = trim(string.gsub(part, '\n', ' '))
            processed_part = escape(processed_part, '\'"', 2)
            --processed_part = string.gsub(processed_part, "'", "\\\\'")
            --processed_part = string.gsub(processed_part, '"', '\\\\"')
            table.insert(result, '%{luaeval("loadstring(\''..processed_part..'\')()")}')
        else
            table.insert(result, part)
        end
    end
    return table.concat(result)
end

satiable.statusline = function()
    return build(satiable.parts)
end

return satiable
