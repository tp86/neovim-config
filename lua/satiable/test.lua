vim.api.nvim_command('LuaReload satiable')
local module = require'satiable'

module.parts.a = function()
    print('called a')
    return 1
end
module.parts.b = function()
    print('called b')
    return 2 + module.parts.a()
end
module.parts.c = 'test'
assert(module.parts.a() == 1)
assert(module.parts.b() == 3)

module.statusline[1] = module.parts.a
module.statusline[2] = module.parts.c
print('before call to statusline')
assert(module.statusline() == [[%{luaeval("require'satiable'.parts.a()")}test]])
print('after call to statusline')
module.parts.a()
