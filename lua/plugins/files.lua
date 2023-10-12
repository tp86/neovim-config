vim.g.loaded_netrwPlugin = 1

return {
  {
    "kyazdani42/nvim-tree.lua",
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
        },
      }
      local nmap = require("common").map.n
      nmap([[<a-\>]], function() vim.cmd("NvimTreeOpen") end, "Open directory tree")
    end,
  },
}
