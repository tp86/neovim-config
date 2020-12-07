vim.api.nvim_command('LuaReload satiable2')

local satiable = require'satiable2'

--  `satiable.statusline` is a table
assert (type(satiable.statusline) == 'table',
        '`satiable.statusline` should be a table')
--  `satiable.statusline` contains `items` table
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
-- but following is possible
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
        '`items` functions can be defined together in a table')
--  functions in the `items` table can still reference (via local variable with short name) to functions defined earlier in the table
assert (satiable.statusline.items.d() == 'cd',
        '`items` functions defined in the table can reference other functions from table defined earlier')
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
        '`items` functions defined in the table can reference other function defined through assignment')
