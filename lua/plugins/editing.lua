return {
  {
    "windwp/nvim-autopairs",
    config = function()
      local autopairs = require("nvim-autopairs")
      autopairs.setup {}
      local single_quote_rule = autopairs.get_rule("'")[1]
      single_quote_rule.not_filetypes = vim.tbl_extend("force", single_quote_rule.not_filetypes, { "rust", "fennel", "janet", "scheme" })
      local backtick_rule = autopairs.get_rule("`")
      backtick_rule.not_filetypes = vim.tbl_extend("force", backtick_rule.not_filetypes or {}, { "fennel", "scheme" })
    end,
  },
  {
    "kylechui/nvim-surround",
    tag = "*",
    config = function()
      require("nvim-surround").setup {}
    end,
  },
  {
    "terrortylor/nvim-comment",
    config = function()
      local keys = "i/"
      require("nvim_comment").setup {
        comment_chunk_text_object = keys,
      }
      local ok, wk = pcall(require, "which-key")
      if ok then
        wk.register({
          keys = "comment",
        }, { mode = "o" })
      end
    end,
  },
  { "gpanders/nvim-parinfer" },
}
