local function cache_table(tbl)
    return setmetatable({}, {
        __index = function(t, k)
            local tbl_value = rawget(tbl, k)
            if type(tbl_value) == "function" then
                tbl_value = tbl_value()
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
