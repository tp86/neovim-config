local function dynamic_access_table(tbl, access_tbl)
    local dynamic_access_table_meta = {
        __index = function(_, field)
            local index_func = access_tbl[field].index
            if index_func then return index_func() end
        end,
        __newindex = function(_, field, value)
            local newindex_func = access_tbl[field].newindex
            if newindex_func then return newindex_func(value) end
        end
    }
    return setmetatable(tbl, dynamic_access_table_meta)
end

return dynamic_access_table
