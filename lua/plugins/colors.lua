return {
  {
    "EdenEast/nightfox.nvim",
    config = function()
      require("nightfox").setup {
        options = {
          styles = {
            comments = "",
          },
        },
      }
    end,
  },
  {
    "projekt0n/github-nvim-theme",
    config = function()
      require("github-theme").setup {
        options = {
          styles = {
            comments = "NONE",
          },
        },
      }
    end,
  },
  {
    "Tsuzat/NeoSolarized.nvim",
    config = function()
      require("NeoSolarized").setup {
        transparent = false,
        terminal_colors = false,
        on_highlights = function(highlights, colors)
          highlights.LineNr.bg = highlights.Normal.bg
        end
      }
    end,
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
    config = function()
      require("rainbow-delimiters.setup").setup {
        highlight = {
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
          "RainbowDelimiterRed",
        }
      }
    end,
  },
  function()
    vim.opt.background = "light"
    vim.cmd.colorscheme("NeoSolarized")
  end,
}
