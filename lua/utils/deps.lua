local function with_dependencies(cmds, action, fallback)
  local all_present = true
  for _, cmd in ipairs(cmds) do
    if vim.fn.executable(cmd) ~= 1 then
      all_present = false
      break
    end
  end
  if all_present then
    return action()
  else
    return fallback()
  end
end

return {
  with_dependencies = with_dependencies,
}
