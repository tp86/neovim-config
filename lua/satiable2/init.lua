local dynamic_access_table = require'satiable2.dynamic_access_table'
local tbl_clear = require'satiable2.utils'.tbl_clear
local update_meta = require'satiable2.utils'.update_meta

local items = {}
local statusline = {}

local statusline_dat = {
    items = {
        index = function()
            return items
        end,
        newindex = function(new_items)
            items = tbl_clear(items)
            if new_items and vim.tbl_count(new_items) > 0 then
                for key, value in pairs(new_items) do
                    items[key] = value
                end
            end
        end,
    },
}
local function add_stl_tbl(index, value)
    -- allow adding number-indexed tables (only) to statusline
    if type(value) == 'table' then
        statusline[index] = value
        return
    end
    error('statusline configuration must be a table')
end
-- index that is not found in `statusline_dat` and is a number should add directly to `statusline`
local statusline_dat_meta = {
    -- indexing key not found in original dat table
    __index = function(_, index)
        if type(index) == 'number' then
            -- inherit number-indexing from returned table
            return {
                -- should have newindex field returning function accepting one argument - new value
                -- this has to be a closure over `index`
                newindex = function(value)
                    return add_stl_tbl(index, value)
                end,
                index = function()
                    return statusline[index]
                end,
            }
        end
    end
}
setmetatable(statusline_dat, statusline_dat_meta)
local stl = dynamic_access_table({}, statusline_dat)
local build_statusline = function(stl_tbl)
    print('building statusline')
end
stl = update_meta(stl, {
    __call = build_statusline,
    __len = function(_)
        return #statusline
    end,
})

local m = {
    statusline = {
        index = function()
            return stl
        end,
        newindex = function(new_statusline_tbl)
            statusline = tbl_clear(statusline)
            if new_statusline_tbl and vim.tbl_count(new_statusline_tbl) > 0 then
                for key, value in pairs(new_statusline_tbl) do
                    statusline[key] = value
                end
            end
        end
    },
}
return dynamic_access_table({}, m)
