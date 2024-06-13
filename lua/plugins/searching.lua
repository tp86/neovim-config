local plugins = {}

local common = require("common")
common.with_dependencies({ "make", "gcc" }, function()
  -- dependencies for nvim-telescope
  table.insert(plugins, { "nvim-lua/plenary.nvim" })
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
      common.map.n("sf", function() builtin.find_files { hidden = true } end, "Find files")
      common.with_dependencies({ "rg" }, function()
        common.map.n("ss", builtin.live_grep, "Search in files")
      end, common.warn("live_grep in telescope not supported due to: ripgrep not available"))
      common.map.n("sb", builtin.buffers, "Find buffers")
      common.map.n("sg", builtin.git_branches, "Find git branches")
      common.map.n("sr", function() builtin.lsp_references{ fname_width = 50, trim_text = true } end, "Find references")

      local ok, wk = pcall(require, "which-key")
      if ok then
        wk.register { s = { name = "+Live search" } }
      end

      telescope.load_extension("fzf")
    end
  })
end, common.warn("nvim-telescope is not installed due to: gcc and/or make not available"))

return plugins
