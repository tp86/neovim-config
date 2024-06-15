local map = require("mappings").map
local with_dependencies = require("utils.deps").with_dependencies
local log = require("utils.log")

local plugins = {
  {
  "folke/flash.nvim",
  config = function()
    local flash = require("flash")
    flash.setup {
      highlight = {
        backdrop = false,
      },
      modes = {
        char = {
          highlight = {
            backdrop = false
          }
        },
        search = {
          enabled = false,
        },
      },
    }
    map.n("sj", flash.jump, "Flash jump")
  end,
},
}

with_dependencies({ "make", "gcc" }, function()
  -- dependencies for nvim-telescope
  table.insert(plugins, require("plugins.common")["plenary"])
  table.insert(plugins, {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
  })
  table.insert(plugins, {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    config = function()
      local telescope = require("telescope")
      telescope.setup {
        defaults = {
          file_ignore_patterns = { ".git/" },
          layout_strategy = "vertical",
          -- path_display = { "shorten" },
        },
      }

      local builtin = require("telescope.builtin")
      map.n("sf", function() builtin.find_files { hidden = true } end, "Find files")
      with_dependencies({ "rg" }, function()
        map.n("ss", builtin.live_grep, "Search in files")
      end, log.warn("live_grep in telescope not supported due to: ripgrep not available"))
      map.n("sb", builtin.buffers, "Find buffers")
      map.n("sg", builtin.git_branches, "Find git branches")
      map.n("sr", function() builtin.lsp_references { fname_width = 50, trim_text = true } end, "Find references")

      local ok, wk = pcall(require, "which-key")
      if ok then
        wk.register { s = { name = "+Live search" } }
      end

      telescope.load_extension("fzf")
    end
  })
end, log.warn("nvim-telescope is not installed due to: gcc and/or make not available"))

return plugins
