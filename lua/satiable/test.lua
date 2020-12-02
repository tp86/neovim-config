local stbl = require'satiable.module'

stbl.items = {
    bufname = function()
        --print('bufname')
        return vim.fn.bufname()
    end
}

stbl.items.filename = function()
    return vim.fn.fnamemodify(stbl.items.bufname, ':t')
end

stbl.statusline = {
    {
        stbl.items.bufname,
        --'bufname',
        --'%=',
        stbl.items.filename,
        --'filename'
    }
}

--vim.api.nvim_set_option('stl', [[%!luaeval("require'satiable.module'.statusline()")]])

local real_funcs = {}
local funcs = {}
local function get_real_func(_, name)
    return real_funcs[name]
end
local function get_func_name(_, name)
    return name
end
local funcs_meta = {
    __index = get_real_func,
    __newindex = function(_, name, func)
        real_funcs[name] = func
    end
}
setmetatable(funcs, funcs_meta)

funcs.func = function()
    return vim.fn.bufname()
end

funcs.func()

local t = setmetatable({}, {
    __call = function(t)
        local s = ''
        for _, name in ipairs(t) do
            s = s .. [[%{luaeval('require"satiable/test".funcs.]]..name..[[()')}]]
        end
        local f_meta = getmetatable(funcs)
        f_meta.__index = get_real_func
        setmetatable(funcs, f_meta)
        return s
    end
})

local m = setmetatable({}, {
    __index = function(_, field)
        if field == 't' then
            local f_meta = getmetatable(funcs)
            f_meta.__index = get_func_name
            setmetatable(funcs, f_meta)
            return t
        end
    end
})

m.t[1] = funcs.func
--print(vim.inspect(real_funcs))
--print(vim.inspect(t))
local stl = m.t()
--print(stl)
--local t_names = {}
--local t_new = function(_, i, v)
--end
--local t_call = function(_)
--    local s = ''
--    for _, fn in ipairs(t_names) do
--        s = s .. 'func'
--    end
--    return s
--end
--
--t[1] = funcs.func
--print(t()) --> 'func'
return {
    funcs = funcs,
    stl = stl
}
