local highlight_excluded_filetypes = { "help", "NvimTree", "dap-repl" }
local function exclude_highlighting(filetype)
  return vim.tbl_contains(highlight_excluded_filetypes, filetype)
      or filetype:match("^dapui_")
end
local colorcolumn_inactive = {}
for i = 1, 999 do colorcolumn_inactive[i] = i end

local dynamic_options = require("dynamic_options")
-- helper for synchronizing dynamic option changes
local function sync_dynamic_option(opt_name, is_bool)
  local function bool_option_callback()
    local new_value = vim.v.option_new
    if new_value == "0" then
      dynamic_options[opt_name] = false
    elseif new_value == "1" then
      dynamic_options[opt_name] = true
    elseif type(new_value) == "boolean" then
      dynamic_options[opt_name] = new_value
    else
      local msg = ('"Value for boolean option %s expected to be 0 or 1, got %s"')
          :format(opt_name, new_value)
      vim.cmd('echoerr ' .. msg)
    end
  end
  local function option_callback()
    dynamic_options[opt_name] = vim.v.option_new
  end
  -- return autocmd definition in format expected by register_autocmds_group
  return {
    "OptionSet",
    pattern = opt_name,
    callback = is_bool and bool_option_callback or option_callback,
  }
end

local o = vim.opt
local ol = vim.opt_local

local register_autocmds_group = require("common").register_autocmds_group
-- colorcolumn in active window, colorize all columns in inactive window
register_autocmds_group("ColorColumn", {
  {
    "BufNewFile",
    "BufRead",
    "BufWinEnter",
    "WinEnter",
    callback = function()
      if not exclude_highlighting(vim.o.filetype) then
        ol.colorcolumn = dynamic_options.colorcolumn
      else
        ol.colorcolumn = {}
      end
    end,
  },
  {
    "WinLeave",
    callback = function()
      if not exclude_highlighting(vim.o.filetype) then
        ol.colorcolumn = colorcolumn_inactive
      end
    end,
  },
  sync_dynamic_option("colorcolumn"),
})

register_autocmds_group("SearchHl", {
  {
    "CmdlineEnter",
    pattern = { "/", "?" },
    callback = function()
      o.hlsearch = true
    end,
  },
  {
    "CmdlineLeave",
    pattern = { "/", "?" },
    callback = function()
      o.hlsearch = dynamic_options.hlsearch
    end,
  },
  sync_dynamic_option("hlsearch", true),
})

-- automating terminal settings
register_autocmds_group("TerminalSettings", {
  {
    "TermOpen",
    callback = function()
      ol.number = false
      ol.relativenumber = false
      ol.signcolumn = "no"
      ol.scrollback = 100000
    end,
  },
  {
    "TermOpen",
    "BufEnter",
    "WinEnter",
    pattern = "term://*",
    callback = function()
      ol.sidescrolloff = 0
    end,
  },
  {
    "TermLeave",
    "BufLeave",
    "WinLeave",
    pattern = "term://*",
    command = "stopinsert",
  },
})

vim.g.autoretab = true
register_autocmds_group("AutoRetab", {
  {
    "BufWrite",
    callback = function()
      if vim.g.autoretab then
        vim.cmd [[ retab ]]
      end
    end,
  },
})

vim.g.autoremovetrailingspaces = true
local cmds = {
  -- remove trailing spaces before cursor line
  [[1,-1s/\v\s+$//]],
  -- remove trailing spaces after cursor line
  [[+1,$s/\v\s+$//]],
  -- remove trailins spaces on current cursor line,
  -- but only if there is something else in the line
  -- if line contains only whitespace characters, leave it as is
  [[s/\v\S\zs\s+$]],
}
register_autocmds_group("AutoRemoveTrailingSpaces", {
  {
    "BufWrite",
    callback = function()
      if vim.g.autoremovetrailingspaces then
        -- remember cursor position
        local view = vim.fn.winsaveview()
        for _, cmd in ipairs(cmds) do
          -- if nothing is found, cmds throw errors, but it's normal situation
          pcall(vim.cmd, cmd)
        end
        -- restore remembered cursor position
        vim.fn.winrestview(view)
      end
    end,
  },
})

register_autocmds_group("QuickfixOpenAfterGrep", {
  {
    "QuickfixCmdPost",
    pattern = "grep",
    command = "copen",
  },
})

vim.diagnostic.config {
  virtual_text = false,
}
o.updatetime = 1000
register_autocmds_group("ShowDiagnostics", {
  {
    "CursorHold",
    callback = function()
      vim.diagnostic.open_float()
    end,
  },
})

if vim.fn.has("nvim-0.10") ~= 0 then
  register_autocmds_group("ForceInlayHintsRefresh", {
    {
      "BufEnter",
      callback = function(ctx)
        local filter = {
          bufnr = ctx.buf,
        }
        vim.lsp.inlay_hint.enable(
          vim.lsp.inlay_hint.is_enabled(filter),
          filter
        )
      end,
    }
  })
end
