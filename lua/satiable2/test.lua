vim.api.nvim_command('LuaReload satiable2')
vim.api.nvim_command('LuaReload satiable2.dynamic_access_table')
vim.api.nvim_command('LuaReload satiable2.utils')

local satiable = require'satiable2'

--  `satiable.statusline` is a table
assert (type(satiable.statusline) == 'table',
        '`satiable.statusline` should be a table')

--  `satiable.statusline` contains existing `items` table
assert (satiable.statusline.items and type(satiable.statusline.items) == 'table',
        '`satiable.statusline.items` should be a table')

--  functions added to `items` should be accessible from functions defined later
local items = satiable.statusline.items
items.a = function()
    print('called a')
    return 'a'
end
items.b = function()
    print('called b')
    return items.a() .. 'b'
end
assert (satiable.statusline.items.b() == 'ab',
        '`items` functions should be able to call other `items` functions defined before')

--  defining whole `satiable.statusline.items` table overwrites existing functions
satiable.statusline.items = {} -- items = {} would overwrite local variable

--  but following is possible
local statusline = satiable.statusline
statusline.items = {}
assert (not(satiable.statusline.items.a or satiable.statusline.items.b),
        'defining whole `satiable.statusline.items` table should overwrite earlier functions')

--  `items` functions can be defined together in a table
satiable.statusline.items = {
    c = function()
        print('called c')
        return 'c'
    end,
    d = function()
        print('called d')
        return items.c() .. 'd'
    end
}
assert (satiable.statusline.items.c() == 'c',
        '`items` functions are able to be defined together in a table')

--  functions in the `items` table can still reference (via local variable with short name) to functions defined earlier in the table
assert (satiable.statusline.items.d() == 'cd',
        '`items` functions defined in the table should be able to reference other functions from table defined earlier')

--  function in the `items` table can still reference (via local variable with short name) to functions defined earlier through assignment
items.e = function()
    print('called e')
    return 'e'
end
items.f = function()
    print('called f')
    return items.c() .. items.e() .. 'f'
end
assert (satiable.statusline.items.f() == 'cef',
        '`items` functions defined in the table should be able to reference other function defined through assignment')

--  `satiable.statusline` table stores number-indexed tables (beside named tables)
for i, t in ipairs(satiable.statusline) do
    assert (type(t) == 'table')
end

--  only tables can be assigned to number-indexed entries of `satiable.statusline`
assert (pcall(function() satiable.statusline[1] = {} end),
        'assigning to number indexes in `satiable.statusline` should accept only tables')
assert (not pcall(function() satiable.statusline[1] = 'some value' end),
        'assigning to number indexes in `satiable.statusline` should accept only tables')
assert (type(satiable.statusline[1]) == 'table',
        'accessing number index of `satiable.statusline` returns the table')

--  statusline configurations are best assigned as a whole table
satiable.statusline = {
    { 'a' },
    { 'b' },
}
--  #satiable.statusline or `[i]pairs(satiable.statusline)` won't work here (requires Lua 5.2)
assert (require'satiable2.utils'.len(satiable.statusline) == 2,
        'assigning new table of tables to `satiable.statusline` overwrites previous assignments')

--  `satiable.statusline` can be called
assert (pcall(satiable.statusline),
        '`satiable.statusline` should be callable')
