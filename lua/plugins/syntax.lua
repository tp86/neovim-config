return {
  { "bakpakin/janet.vim" },
  { "jaawerth/fennel.vim" },
  { "stefanos82/nelua.vim" },
  { "erde-lang/vim-erde" },
  {
    "vim-crystal/vim-crystal",
    config_before = function()
      vim.g.crystal_auto_format = 0
      vim.g.crystal_define_mappings = 0
      vim.g.crystal_enable_completion = 0
    end,
  },
  { "andreypopp/vim-terra" },
  {
    "MeanderingProgrammer/markdown.nvim",
    config = function()
      local ok, ts = pcall(require, "nvim-treesitter.install")
      if ok then
        ts.ensure_installed {
          "markdown",
          "markdown_inline",
        }
      end
      require("render-markdown").setup()
    end,
  },
}
