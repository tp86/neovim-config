local function crystal()
  -- for jlcrochet/vim-crystal
  -- vim.g.crystal_simple_indent = 1

  -- for vim-crystal/vim-crystal
  vim.g.crystal_auto_format = 0
  vim.g.crystal_define_mappings = 0
  vim.g.crystal_enable_completion = 0

  return { "vim-crystal/vim-crystal" }
end
return {
  { "bakpakin/janet.vim" },
  { "jaawerth/fennel.vim" },
  { "stefanos82/nelua.vim" },
  { "erde-lang/vim-erde" },
  crystal(),
  { "andreypopp/vim-terra" },
}
