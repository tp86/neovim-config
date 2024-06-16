local augroup = require("auto").augroup

local function ftgroup(filetype)
  return function(group, autocmds)
    for _, autocmd in ipairs(autocmds) do
      if vim.list_contains(autocmd, "FileType") then
        autocmd.pattern = filetype
      else
        autocmd.pattern = "*." .. filetype
      end
    end
    augroup(group, autocmds)
  end
end

return {
  ftgroup = ftgroup
}
