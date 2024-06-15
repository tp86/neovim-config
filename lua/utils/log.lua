local function warn(msg)
  return function()
    vim.cmd [[ echohl WarningMsg ]]
    vim.cmd('echom "' .. msg .. '"')
    vim.cmd [[ echohl none ]]
  end
end

return {
  warn = warn,
}
