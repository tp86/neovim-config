return {
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      local gitsigns = require("gitsigns")
      gitsigns.setup {
        signs = {
          changedelete = {
            hl = "GitSignsDelete",
            text = "┃",
          },
        },
        on_attach = function(bufnr)
          local common = require("common")
          common.map.n("<localleader>h", gitsigns.preview_hunk, "Preview git hunk")
          common.map.n("<localleader>b", gitsigns.blame_line, "Blame line")
        end,
        current_line_blame = true,
      }
    end,
  },
  -- dependency for diffview and neogit
  { "nvim-lua/plenary.nvim" },
  {
    "sindrets/diffview.nvim",
    config = function()
      require("diffview").setup {
        view = {
          merge_tool = {
            layout = "diff3_mixed",
            disable_diagnostics = true,
          },
        },
      }
    end,
  },
  {
    "TimUntersberger/neogit",
    config = function()
      local opts = {
        disable_commit_confirmation = true,
        disable_insert_on_commit = true,
        kind = "vsplit",
        status = {
          kind = "vsplit",
        },
        commit_editor = {
          kind = "split",
        },
      }
      local ok = pcall(require, "diffview")
      if ok then
        opts.integrations = { diffview = true }
      end
      require("neogit").setup(opts)
    end,
  },
  {
    "FabijanZulj/blame.nvim"
  },
}
