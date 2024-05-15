return {
  require("plugins.common")["web-devicons"],
  {
    "nvim-tree/nvim-tree.lua",
    config_before = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
    config = function()
      require("nvim-tree").setup {
        actions = {
          open_file = {
            quit_on_open = true,
          },
        },
        view = {
          side = "right",
          width = 50,
          preserve_window_proportions = true,
        },
        filters = {
          custom = { "__pycache__", ".git$" },
        },
        sync_root_with_cwd = true,
        update_focused_file = {
          enable = true,
        },
        renderer = {
          highlight_opened_files = "name",
          icons = {
            glyphs = {
              folder = {
                -- requires nvim-web-devicons
                default = "󰉋",
                open = "󰝰",
                empty = "󰉖",
                empty_open = "󰷏",
              }
            }
          }
        },
      }
      local nmap = require("common").map.n
      nmap([[<a-\>]], function() vim.cmd("NvimTreeOpen") end, "Open directory tree")
    end,
  },
}
