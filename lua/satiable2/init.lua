local dynamic_access_table = require'satiable2.dynamic_access_table'
local tbl_clear = require'satiable2.utils'.tbl_clear

local items = {}

local statusline_dat = {
    items = {
        get = function()
            return items
        end,
        set = function(new_items)
            items = tbl_clear(items)
            if new_items and vim.tbl_count(new_items) > 0 then
                for key, value in pairs(new_items) do
                    items[key] = value
                end
            end
        end,
    },
}
local statusline = dynamic_access_table(statusline_dat)

local m = {
    statusline = {
        get = function()
            return statusline
        end,
        set = function(new_statusline_tbl)
            statusline = tbl_clear(statusline)
            if new_statusline_tbl and vim.tbl_count(new_statusline_tbl) > 0 then
                for key, value in pairs(new_statusline_tbl) do
                    statusline[key] = value
                end
            end
        end
    },
}
return dynamic_access_table(m)
