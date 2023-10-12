local common = require("common")

local plugins = {
  {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup()
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local enabled_servers = {}
      common.with_dependencies({ "lua-language-server" }, function()
        enabled_servers.lua_ls = { settings = {} }
      end, common.warn("lua-language-server not available"))

      local lspconfig = require("lspconfig")
      for server, config in pairs(enabled_servers) do
        config.on_attach = common.lsp.on_attach
        config.capabilities = common.lsp.capabilities
        lspconfig[server].setup(config)
      end
    end,
  },
  -- additional extensions for nvim-cmp
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "saadparwaiz1/cmp_luasnip" },
  {
    "L3MON4D3/LuaSnip",
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    config = function()
      vim.opt.completeopt = { "menu", "menuone", "noselect" }
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        sources = cmp.config.sources {
          { name = "nvim_lsp", keyword_length = 2 },
          { name = "buffer", keyword_length = 3 },
          { name = "luasnip", keyword_length = 2 },
        },
        mapping = cmp.mapping.preset.insert {
          ["<c-j>"] = cmp.mapping(function()
            if cmp.visible() then
              cmp.select_next_item()
            else
              cmp.complete()
            end
          end, { "i", "s" }),
          ["<c-k>"] = cmp.mapping(function()
            if cmp.visible() then
              cmp.select_prev_item()
            else
              cmp.complete()
            end
          end, { "i", "s" }),
          ["<c-h>"] = cmp.mapping(function(fallback)
            if luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<c-l>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.confirm { select = true }
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<c-u>"] = cmp.mapping.scroll_docs(-4),
          ["<c-d>"] = cmp.mapping.scroll_docs(4),
          ["<c-e>"] = cmp.mapping.abort(),
        },
      }
    end,
  },
  {
    "phaazon/hop.nvim",
    branch = "v2",
    config = function()
      local hop = require("hop")
      hop.setup()
      local directions = require("hop.hint").HintDirection
      local common = require("common")
      local map_opts = { remap = true }
      common.map("f", function() hop.hint_char1 { direction = directions.AFTER_CURSOR } end, "Go to char forward", map_opts)
      common.map("F", function() hop.hint_char1 { direction = directions.BEFORE_CURSOR } end, "Go to char backward", map_opts)
      common.map("t", function() hop.hint_char1 { direction = directions.AFTER_CURSOR, hint_offset = -1} end, "Go till char forward", map_opts)
      common.map("T", function() hop.hint_char1 { direction = directions.BEFORE_CURSOR, hint_offset = 1 } end, "Go till char backward", map_opts)
    end,
  },
}

common.with_dependencies({ "gcc" }, function()
  -- additional extensions for nvim-treesitter
  table.insert(plugins, { "p00f/nvim-ts-rainbow" })
  table.insert(plugins, { "nvim-treesitter/nvim-treesitter-textobjects" })
  table.insert(plugins, {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdateSync",
    --[[
    function()
      require("nvim-treesitter.install").update { with_sync = true }
    end,
    --]]
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = { "python", "lua", "janet_simple" },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = true,
        },
        rainbow = {
          enable = true,
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
              ["ac"] = "@call.outer",
              ["ic"] = "@call.inner",
              ["ao"] = "@class.outer",
              ["io"] = "@class.inner",
              ["al"] = "@loop.outer",
              ["il"] = "@loop.inner",
            },
          },
        },
      }
      local ok, wk = pcall(require, "which-key")
      if ok then
        wk.register({
          ["af"] = "function",
          ["if"] = "function",
          ["aa"] = "parameter",
          ["ia"] = "parameter",
          ["ac"] = "call",
          ["ic"] = "call",
          ["ao"] = "class",
          ["io"] = "class",
          ["al"] = "loop",
          ["il"] = "loop",
        }, { mode = "o" })
      end
      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "nvim-treesitter#foldexpr()"
      vim.opt.foldenable = false
    end,
  })
end, common.warn("nvim-treesitter is not installed due to: gcc not available"))

return plugins
