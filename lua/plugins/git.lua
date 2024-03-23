local ok, wk = pcall(require, "which-key")
if ok then
  wk.register { ["<localleader>g"] = { name = "+Git" } }
end
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
          common.map.n("<localleader>gh", gitsigns.preview_hunk, "Preview git hunk")
          common.map.n("<localleader>gb", gitsigns.blame_line, "Blame line")
          common.map.n("]h", gitsigns.next_hunk, "Go to next git hunk")
          common.map.n("[h", gitsigns.prev_hunk, "Go to previous git hunk")
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
      local neogit = require("neogit")
      neogit.setup(opts)
      local common = require("common")
      common.map.n("<localleader>gg", neogit.open, "Open Neogit window")
    end,
  },
  {
    "FabijanZulj/blame.nvim"
  },
}
