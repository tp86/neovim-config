local map = require("common").map

-- probably to be removed
map.n("<a-h>", "<c-w>h", "Go to the left window")
map.n("<a-j>", "<c-w>j", "Go to the down window")
map.n("<a-k>", "<c-w>k", "Go to the up window")
map.n("<a-l>", "<c-w>l", "Go to the right window")
map.v("<a-h>", "<c-w>h", "Go to the left window")
map.v("<a-j>", "<c-w>j", "Go to the down window")
map.v("<a-k>", "<c-w>k", "Go to the up window")
map.v("<a-l>", "<c-w>l", "Go to the right window")

map.i("<a-h>", [[<c-\><c-n><c-w>h]], "Go to the left window")
map.i("<a-j>", [[<c-\><c-n><c-w>j]], "Go to the down window")
map.i("<a-k>", [[<c-\><c-n><c-w>k]], "Go to the up window")
map.i("<a-l>", [[<c-\><c-n><c-w>l]], "Go to the right window")
map.t("<a-h>", [[<c-\><c-n><c-w>h]], "Go to the left window")
map.t("<a-j>", [[<c-\><c-n><c-w>j]], "Go to the down window")
map.t("<a-k>", [[<c-\><c-n><c-w>k]], "Go to the up window")
map.t("<a-l>", [[<c-\><c-n><c-w>l]], "Go to the right window")

-- resize windows
map.n("<a-s-h>", "<cmd>silent vertical resize -3<cr>", "Decrease window width by 3")
map.n("<a-s-j>", "<cmd>silent resize +3<cr>", "Increase window height by 3")
map.n("<a-s-k>", "<cmd>silent resize -3<cr>", "Decrease window height by 3")
map.n("<a-s-l>", "<cmd>silent vertical resize +3<cr>", "Increase window width by 3")

map.i("<c-j>", "<c-n>", "Find next match")
map.i("<c-k>", "<c-p>", "Find previous match")

map("H", "^", "Start of line (non-blank)")
map("L", "$", "End of line")

map.n("j", "gj", "Go to the next display line")
map.n("k", "gk", "Go to the previous display line")

local expr_opts = { expr = true }

local function cwildmap(key, alt, desc)
  local wild_menu = vim.fn.wildmenumode
  map.c(key, function()
    if wild_menu() == 1 then
      return alt
    else
      return key
    end
  end, desc, expr_opts)
end

cwildmap("<c-h>", "<up>", "Select previous in wildmenu")
cwildmap("<c-l>", "<down>", "Select next in wildmenu")
cwildmap("<c-k>", "<left>", "Switch to previous selections in wildmenu")
cwildmap("<c-j>", "<right>", "Switch to next selections in wildmenu")
cwildmap("<left>", "<up>", "Select previous in wildmenu")
cwildmap("<right>", "<down>", "Select next in wildmenu")
cwildmap("<up>", "<left>", "Switch to previous selections in wildmenu")
cwildmap("<down>", "<right>", "Switch to next selections in wildmenu")

local function put_empty_lines(how_many, where)
  local current_position = vim.fn.getcurpos()
  local new_position = { current_position[2], current_position[5] }
  local line_to_insert = new_position[1]
  if where == "above" then
    line_to_insert = new_position[1] - 1
    new_position[1] = new_position[1] + how_many
  elseif where == "below" then
    -- for future use
  end
  local lines = {}
  for i = 1, how_many do lines[i] = "" end
  vim.fn.append(line_to_insert, lines)
  vim.fn.cursor(new_position)
end
map.n("<a-O>", function() put_empty_lines(vim.v.count1, "above") end, "Insert empty line(s) above")
map.n("<a-o>", function() put_empty_lines(vim.v.count1, "below") end, "Insert empty line(s) below")

map.n("<a-t>", ":sp|term<cr>", "Open terminal")
map.t("<esc>", [[<c-\><c-n>]], "Normal mode")
map.t("<c-b>", [[<c-\><c-n><c-b>]], "Scroll terminal up")
map.t("<c-u>", [[<c-\><c-n><c-u>]], "Scroll terminal up by half screen")

map.v("/", 'y/<c-r>"<cr>', "Search selection forward")
map.v("g/", "/", "Search forward")
map.v("?", 'y?<c-r>"<cr>', "Search selection backward")
map.v("g?", "?", "Search backward")
map.n("g*", "<cmd>silent grep <cword><cr>", "grep word under cursor")

local function insert_mode_put()
  local keys = "<esc>g"
  local column = vim.fn.col(".")
  if column == 1 then
    keys = keys .. "P"
  else
    keys = keys .. "p"
  end
  if column == vim.fn.col("$") then
    keys = keys .. "a"
  else
    keys = keys .. "i"
  end
  return keys
end
map.i("<a-v>", insert_mode_put, "Paste in insert mode", expr_opts)

map.n("<backspace>", "<c-6>", "Edit the alternate file")
