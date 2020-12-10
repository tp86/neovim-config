local tbl_clear = require'satiable2.utils'.tbl_clear

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

local function access_during_assignment(tbl)
    return {
        index = function()
            return tbl
        end,
        newindex = function(new_tbl)
            tbl = tbl_clear(tbl)
            if new_tbl and vim.tbl_count(new_tbl) > 0 then
                for key, value in pairs(new_tbl) do
                    tbl[key] = value
                end
            end
        end
    }
end

return {
    dynamic_access_table = dynamic_access_table,
    access_during_assignment = access_during_assignment
}
