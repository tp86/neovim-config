local function dynamic_access_table(tbl)
    local dynamic_access_table_meta = {
        __index = function(_, field)
            local getter = tbl[field].get
            if getter then return getter() end
        end,
        __newindex = function(_, field, value)
            local setter = tbl[field].set
            if setter then return setter(value) end
        end,
        __metatable = {}
    }
    return setmetatable({}, dynamic_access_table_meta)
end

return dynamic_access_table
