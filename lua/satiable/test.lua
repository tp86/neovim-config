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
