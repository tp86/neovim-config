return {
  {
    "jmcantrell/vim-virtualenv",
    config = function()
      vim.g.virtualenv_directory = os.getenv("HOME") .. "/.venv"
    end,
  },
}
