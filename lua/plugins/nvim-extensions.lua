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
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "rcarriga/cmp-dap" },
  {
    "L3MON4D3/LuaSnip",
    config = function()
      require("luasnip").cleanup()
      require("luasnip.loaders.from_snipmate").lazy_load()
      common.map.i("<esc>", function()
        require("luasnip").unlink_current()
        -- TODO try to refer to existing key
        vim.cmd.stopinsert()
      end, "Clear snippet jump history on leaving insert mode")
    end,
  },
  { "saadparwaiz1/cmp_luasnip" },
  { "onsails/lspkind.nvim" },
  function()
    -- unregister duplicated old sources on config resourcing
    local cmp = require("cmp")
    local sources = {}
    for _, cfg in pairs(cmp.core.sources) do
      local source = sources[cfg.name] or {}
      table.insert(source, cfg.id)
      sources[cfg.name] = source
    end
    for _, ids in pairs(sources) do
      for i = 1, #ids - 1 do
        cmp.unregister_source(ids[i])
      end
    end
  end,
  {
    "hrsh7th/nvim-cmp",
    config = function()
      vim.opt.completeopt = { "menu", "menuone", "noselect" }
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local dap = require("cmp_dap")
      local lspkind = require("lspkind")
      cmp.setup {
        enabled = function()
          return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt" or (dap and dap.is_dap_buffer())
        end,
        formatting = {
          format = lspkind.cmp_format {
            mode = "symbol_text",
            menu = {
              buffer = "[buf]",
              nvim_lsp = "[LSP]",
              luasnip = "[snip]",

            },
          },
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        sources = {
          { name = "nvim_lsp", keyword_length = 2 },
          { name = "luasnip",  keyword_length = 2 },
          { name = "buffer",   keyword_length = 3 },
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
            if luasnip.locally_jumpable(-1) then
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
      cmp.setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
        sources = {
          { name = "dap" },
        }
      })
    end,
  },
  {
    "folke/flash.nvim",
    config = function()
      local flash = require("flash")
      flash.setup {
        highlight = {
          backdrop = false,
        },
        modes = {
          char = {
            highlight = {
              backdrop = false
            }
          },
          search = {
            enabled = false,
          },
        },
      }
      local common = require("common")
      common.map.n("<leader>j", flash.jump, "Flash jump")
    end,
  },
  {
    "mfussenegger/nvim-dap",
    config = function()
      vim.fn.sign_define("DapBreakpoint", { text = '●', texthl = 'Error', linehl = '', numhl = '' })
      vim.fn.sign_define("DapStopped", { text = '▶', texthl = '', linehl = '', numhl = '' })
      local nmap = require("common").map.n
      local dap = require("dap")
      nmap("<a-7>", dap.continue, "Debug: continue")
      nmap("<a-8>", dap.step_over, "Debug: step over")
      nmap("<a-9>", dap.step_into, "Debug: step into")
      nmap("<a-0>", dap.step_out, "Debug: step out")
      nmap("<localleader>b", dap.toggle_breakpoint, "Toggle debug breakpoint")
      nmap("<localleader>B", dap.clear_breakpoints, "Delete all breakpoints")
      nmap("<localleader><a-->", dap.terminate, "Debug: terminate")
    end,
  },
  {
    "nvim-neotest/nvim-nio",
  },
  {
    "rcarriga/nvim-dap-ui",
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup {}
      dap.listeners.after.launch.dapui_config = dapui.open
      dap.listeners.after.attach.dapui_config = dapui.open
      dap.listeners.before.event_terminated.dapui_config = dapui.close
      dap.listeners.before.event_exited.dapui_config = dapui.close
    end,
  },
  {
    "leoluz/nvim-dap-go",
    -- config = function()
    --   require("dap-go").setup {}
    -- end,
  }
}

common.with_dependencies({ "gcc" }, function()
  -- additional extensions for nvim-treesitter
  --table.insert(plugins, { "p00f/nvim-ts-rainbow" })
  table.insert(plugins, { "nvim-treesitter/nvim-treesitter-textobjects" })
  table.insert(plugins, {
    "nvim-treesitter/nvim-treesitter",
    build = function()
      local ok, install = pcall(require, "nvim-treesitter.install")
      if ok then
        install.update { with_sync = true }
      end
    end,
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = { "python", "lua", "janet_simple" },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = true,
        },
        --[[rainbow = {
          enable = true,
        },--]]
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
  table.insert(plugins, {
    "theHamsta/nvim-dap-virtual-text",
    config = function()
      require("nvim-dap-virtual-text").setup {
        enabled_commands = false,

      }
    end,
  })
end, common.warn("nvim-treesitter is not installed due to: gcc not available"))

return plugins
