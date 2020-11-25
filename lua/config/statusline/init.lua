local parts = require'config.statusline.parts.highlighted'

local function build(parts)
    local stl = ''
    for _, part in ipairs(parts) do
        local part_type = type(part)
        local part_result
        if part_type == 'function' then
            part_result = part()
        elseif part_type == 'string' or part_type == 'number' then
            part_result = part
        else
            part_result = ''
        end
        stl = stl .. part_result
    end
    return stl
end

local filetype_stl = {
    help = {parts.filename}
}

local default_stl = {
    parts.cwd,
    parts.filename
}

return {
    active = function()
        local filetype = vim.fn.nvim_buf_get_option(0, 'filetype')
        return build(filetype_stl[filetype] or default_stl)
    end,
    inactive = function()
    end
}
