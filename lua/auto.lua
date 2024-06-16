local helpers = require("auto.helpers")
local augroup = helpers.augroup
local sync_dynamic_option = helpers.sync_dynamic_option
local dynamic_options = require("options").dynamic

local o = vim.opt
local ol = vim.opt_local

-- colorcolumn in active window, colorize all columns in inactive window
local colorcolumn_inactive = {}
for i = 1, 999 do colorcolumn_inactive[i] = i end
-- TODO extend in plugins
local highlight_excluded_filetypes = { "help", "NvimTree", "dap-repl" }
local function exclude_highlighting(filetype)
  return vim.tbl_contains(highlight_excluded_filetypes, filetype)
      or filetype:match("^dapui_")
end
augroup("ColorColumn", {
  {
    "BufNewFile",
    "BufRead",
    "BufWinEnter",
    "WinEnter",
    callback = function()
      if exclude_highlighting(vim.o.filetype) then
        ol.colorcolumn = {}
      else
        ol.colorcolumn = dynamic_options.colorcolumn
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

augroup("SearchHl", {
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
  sync_dynamic_option("hlsearch"),
})

-- automating terminal settings
augroup("TerminalSettings", {
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
augroup("AutoRetab", {
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
augroup("AutoRemoveTrailingSpaces", {
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

augroup("QuickfixOpenAfterGrep", {
  {
    "QuickfixCmdPost",
    pattern = "grep",
    command = "copen",
  },
})

augroup("ShowDiagnostics", {
  {
    "CursorHold",
    callback = function()
      vim.diagnostic.open_float()
    end,
  },
})

augroup("ForceInlayHintsRefresh", {
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

require("auto.go")

return {
  augroup = augroup,
}
