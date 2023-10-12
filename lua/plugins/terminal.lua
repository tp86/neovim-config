local jobsend = vim.fn.jobsend

local function lua_send(eol_char)
  eol_char = eol_char or "\n"
  return function(lines)
    local pattern = "local (.+)$"
    -- if single line, remove local regardless of indentation
    if #lines == 1 then
      pattern = "%s*" .. pattern
    end
    pattern = "^" .. pattern
    for i, line in ipairs(lines) do
      local line_without_leading_local = line:match(pattern)
      if line_without_leading_local then
        -- replace current line with stripped one
        lines[i] = line_without_leading_local
      end
    end
    local payload = table.concat(lines, "\n") .. eol_char
    jobsend(vim.g.send_target.term_id, payload)
  end
end

return {
  {
    "mtikekar/nvim-send-to-term",
    config = function()
      vim.g.send_disable_mapping = true
      local common = require("common")
      common.map.n("xx", "<Plug>SendLine", "Send current line to terminal")
      common.map.n("x", "<Plug>Send", "Send to terminal")
      common.map.v("x", "<Plug>Send", "Send to terminal")
      local ok, wk = pcall(require, "which-key")
      if ok then
        wk.register { x = { name = "+Send to terminal" } }
      end
      vim.g.send_multiline = {
        lua = { send = lua_send() },
      }
    end,
  },
}
