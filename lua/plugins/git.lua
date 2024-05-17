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
        current_line_blame_formatter = " <author>, <author_time:%Y-%m-%d> - <summary>"
      }
      local register_autocmds_group = require("common").register_autocmds_group
      local function colorssetup()
        local function inttocolorstring(n)
          return "#" .. string.format("%06x", n)
        end
        local current_line_blame_hl_name = "GitSignsCurrentLineBlame"
        local opts = {
          italic = true,
          fg = inttocolorstring(vim.api.nvim_get_hl(0, { name = "NonText" }).fg)
        }
        vim.api.nvim_set_hl(0, current_line_blame_hl_name, opts)
      end
      colorssetup()
      register_autocmds_group("GitSignsCurrentLineBlameCustomize", {
        {
          "ColorScheme",
          callback = colorssetup,
        },
      })
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
    "NeogitOrg/neogit",
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
          show_staged_diff = false,
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
      -- make highlighting more consistent
      vim.api.nvim_set_hl(0, "NeogitHunkHeader", { link = "NeogitHunkHeaderHighlight" })
      vim.api.nvim_set_hl(0, "NeogitHunkHeaderCursor", { link = "NeogitHunkHeaderHighlight" })
      vim.api.nvim_set_hl(0, "NeogitDiffContext", { link = "NeogitDiffContextHighlight" })
      vim.api.nvim_set_hl(0, "NeogitDiffContextCursor", { link = "NeogitDiffContextHighlight" })
      vim.api.nvim_set_hl(0, "NeogitDiffAdd", { link = "DiffAdd" })
      vim.api.nvim_set_hl(0, "NeogitDiffAddHighlight", { link = "NeogitDiffAdd" })
      vim.api.nvim_set_hl(0, "NeogitDiffAddCursor", { link = "NeogitDiffAdd" })
      vim.api.nvim_set_hl(0, "NeogitDiffDelete", { link = "DiffDelete" })
      vim.api.nvim_set_hl(0, "NeogitDiffDeleteHighlight", { link = "NeogitDiffDelete" })
      vim.api.nvim_set_hl(0, "NeogitDiffDeleteCursor", { link = "NeogitDiffDelete" })
      vim.api.nvim_set_hl(0, "NeogitDiffHeaderCursor", { link = "NeogitDiffHeader" })
    end,
  },
  {
    "FabijanZulj/blame.nvim",
    config = function()
      require("blame").setup()
    end,
  },
}
