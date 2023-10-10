local common = require("common", true)
common.with_dependencies({ "git" }, function()
  local pckr_path = vim.fn.stdpath("data") .. "/pckr/pckr.nvim"

  if not vim.loop.fs_stat(pckr_path) then
    vim.fn.system({
      'git',
      'clone',
      "--filter=blob:none",
      'https://github.com/lewis6991/pckr.nvim',
      pckr_path
    })
  end

  vim.opt.rtp:prepend(pckr_path)
end, common.warn "git not found, cannot setup plugins")

require('pckr').add{
   "EdenEast/nightfox.nvim",
    config = function()
      require("nightfox").setup {
        options = {
          styles = {
            comments = ""
          },
        },
      }
      vim.cmd [[ colorscheme duskfox ]]
    end,
  }

require('pckr').add{
   "folke/which-key.nvim",
    config = function()
      require("which-key").setup()
    end,
  }

