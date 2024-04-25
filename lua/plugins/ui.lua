-- helper functions for custom components
--
-- function combinators
-- negate predicate
local function flip(predicate)
  return function()
    return not predicate()
  end
end
-- any of predicates is fullfilled
local function any(predicates)
  return function()
    for _, predicate in ipairs(predicates) do
      if predicate() then return true end
    end
  end
end

-- predicates
-- is current filetype one of listed predicate factory
-- for use in conditional displaying components
local function filetype_in(filetypes)
  return function()
    return vim.tbl_contains(filetypes, vim.opt_local.filetype:get())
  end
end
-- is current buffer type one of listed predicate factory
-- for use in conditional displaying components
local function buftype_in(buftypes)
  return function()
    return vim.tbl_contains(buftypes, vim.opt_local.buftype:get())
  end
end
local is_help = filetype_in { "help" }
local is_terminal = buftype_in { "terminal" }

-- component functions
local fnamemodify = vim.fn.fnamemodify
-- get shortened cwd
local function short_cwd()
  return vim.fn.pathshorten(fnamemodify(vim.fn.getcwd(), ":~"))
end
-- custom filename (shortened, relative to cwd)
local function filename()
  local bufname = vim.fn.bufname()
  ---@diagnostic disable-next-line:redefined-local
  local filename = fnamemodify(bufname, ":t")
  if #filename == 0 then
    return "[No Name]"
  end
  if is_help() then
    return filename
  end
  local full_bufname = fnamemodify(bufname, ":p")
  if is_terminal() then
    local splitted_terminal_uri = vim.fn.split(full_bufname, ":")
    local shell_pid = fnamemodify(splitted_terminal_uri[2], ":t")
    local shell_exec = fnamemodify(splitted_terminal_uri[#splitted_terminal_uri], ":t")
    return ("%s:%s:%s"):format(splitted_terminal_uri[1], shell_pid, shell_exec)
  end
  local full_cwd = fnamemodify(vim.fn.getcwd(), ":p")
  local relative_path = vim.fn.matchstr(full_bufname, [[\v^]] .. full_cwd .. [[\zs.*$]])
  if #relative_path == 0 then
    relative_path = full_bufname
  end
  local relative_dir = fnamemodify(relative_path, ":h")
  if relative_dir == "." then
    return filename
  else
    return vim.fn.pathshorten(relative_dir .. "/" .. filename, 5)
  end
end
-- custom modified flags
local function flags()
  if vim.opt_local.readonly:get() or not vim.opt_local.modifiable:get() then
    return "[-]"
  elseif vim.opt_local.modified:get() then
    return "[+]"
  else
    return ""
  end
end
-- python virtualenv
local function virtualenv()
  local venv = os.getenv("VIRTUAL_ENV")
  if venv then
    return ("(%s)"):format(fnamemodify(venv, ":t"))
  end
  return ""
end
-- lsp clients
local function lsp_clients()
  local client_names = {}
  for _, client in pairs(vim.lsp.buf_get_clients()) do
    table.insert(client_names, client.config.name)
  end
  return table.concat(client_names, ",")
end

-- formatting functions
--
-- git branch formatter
local function branch_fmt(str)
  if #str > 8 then
    str = str:sub(1, 8) .. "…"
  end
  local changes = vim.fn["git_info#changes"]()
  if changes.changed + changes.untracked > 0 then
    str = str .. "*"
  end
  return str
end
-- end of helpers }}}

return {
  require("plugins.common")["web-devicons"],
  {
    -- for git (branch & status) component
    "rktjmp/git-info.vim",
  },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup {
        sections = {
          lualine_a = {
            {
              short_cwd,
              on_click = function()
                pcall(vim.cmd, "NvimTreeOpen")
              end,
            },
          },
          lualine_b = {
            {
              "branch",
              fmt = branch_fmt,
              cond = flip(is_terminal),
              on_click = function()
                local ok, telescope = pcall(require, "telescope.builtin")
                if ok then
                  telescope.git_branches()
                end
              end,
            },
          },
          lualine_c = {
            {
              filename,
              separator = {},
              cond = flip(filetype_in { "NvimTree", "DiffviewFiles" }),
            },
            {
              flags,
              cond = flip(any {
                filetype_in { "NvimTree", "DiffviewFiles", "NeogitStatus" },
                is_terminal,
              }),
            },
          },
          lualine_x = {
            {
              "filetype",
              cond = flip(filetype_in { "NvimTree", "DiffviewFiles", "NeogitStatus" }),
            },
            {
              virtualenv,
              cond = filetype_in { "python" },
            },
            {
              lsp_clients,
            },
          },
          lualine_y = {
            {
              "diagnostics",
              icons_enabled = false,
              on_click = function()
                vim.diagnostic.setloclist()
              end,
            },
          },
          lualine_z = {},
        },
        tabline = {
          lualine_a = {
            "tabs",
          },
        },
      }

      -- show tabline only when there are multiple tabs
      vim.opt.showtabline = 1
    end,
  },
}
