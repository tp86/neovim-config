local function cache_table(tbl)
    return setmetatable({}, {
        __index = function(t, k)
            local tbl_value = rawget(tbl, k)
            local callable, result = pcall(tbl_value)
            if callable then
                tbl_value = result
            end
            rawset(t, k, tbl_value)
            return rawget(t, k)
        end
    })
end

return setmetatable({}, {
    __call = function(_, t)
        return cache_table(t)
    end
})
