local function tbl_clear(tbl)
    if vim.tbl_count(tbl) > 0 then
        for key in pairs(tbl) do
            rawset(tbl, key, nil)
        end
    end
    return tbl
end

return {
    tbl_clear = tbl_clear
}
