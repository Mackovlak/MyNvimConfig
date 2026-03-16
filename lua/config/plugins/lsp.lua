-- ============================================================
--  lsp.lua — Mason + nvim-lspconfig + nvim-cmp
-- ============================================================
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Mason: install/manage LSP servers, linters, formatters
      { "williamboman/mason.nvim",            build = ":MasonUpdate" },
      { "williamboman/mason-lspconfig.nvim" },

      -- Completion
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-cmdline",

      -- Snippets
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",

      -- JSX/Tailwind extras
      "windwp/nvim-autopairs",
      "windwp/nvim-ts-autotag",
      "roobert/tailwindcss-colorizer-cmp.nvim",

      -- Fancy LSP UI: hover docs, signature help
      { "j-hui/fidget.nvim",
        opts = {
          notification = {
            window = {
              -- Correct key per fidget docs: avoid (not avoid_ftypes)
              avoid = { "NvimTree" },
            },
          },
        },
      },
      { "folke/neodev.nvim",  opts = {} },         -- Neovim Lua dev environment
    },

    config = function()
      -- ── Mason ───────────────────────────────────────────────────────────────
      require("mason").setup({
        ui = {
          border = "rounded",
          icons  = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
        },
      })

      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "ts_ls",
          "tailwindcss",
          "cssls",
          "html",
          "jsonls",
          "bashls",
          "pyright",
        },
        automatic_installation = true,
        automatic_enable       = false,
      })

      -- Auto-install formatters + linters via mason
      -- This fixes the conform "command not found" warnings
      local ensure_tools = {
        "prettierd",   -- JS/TS/CSS/HTML/JSON/MD/YAML formatter
        "stylua",      -- Lua formatter
        "black",       -- Python formatter
        "isort",       -- Python import sorter
        "shfmt",       -- Shell formatter
        "eslint_d",    -- JS/TS linter (fast daemon)
        "shellcheck",  -- Shell linter
      }
      local mr_ok, mr = pcall(require, "mason-registry")
      if mr_ok then
        mr.refresh(function()
          for _, tool in ipairs(ensure_tools) do
            local p_ok, p = pcall(mr.get_package, tool)
            if p_ok and not p:is_installed() then
              p:install()
            end
          end
        end)
      end

      -- ── Snippets ────────────────────────────────────────────────────────────
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()
      luasnip.config.setup({})

      -- ── Completion ──────────────────────────────────────────────────────────
      local cmp     = require("cmp")
      local cmp_lsp = require("cmp_nvim_lsp")
      local capabilities = cmp_lsp.default_capabilities()

      -- Autopairs
      local ap_ok, cmp_ap = pcall(require, "nvim-autopairs.completion.cmp")
      if ap_ok then
        require("nvim-autopairs").setup({ check_ts = true })
        cmp.event:on("confirm_done", cmp_ap.on_confirm_done())
      end

      -- Tailwind colorizer in completion
      local tw_ok, tw_cmp = pcall(require, "tailwindcss-colorizer-cmp")
      if tw_ok then tw_cmp.setup({}) end

      -- Autotag for JSX/HTML
      local at_ok = pcall(require, "nvim-ts-autotag")
      if at_ok then require("nvim-ts-autotag").setup({}) end

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"]     = cmp.mapping.select_next_item(),
          ["<C-p>"]     = cmp.mapping.select_prev_item(),
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        completion  = { keyword_length = 1 },
        performance = { debounce = 80, throttle = 60 },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "nvim_lua" },
        }, {
          { name = "buffer", keyword_length = 3 },
          { name = "path" },
        }),
        formatting = tw_ok and { format = tw_cmp.formatter } or nil,
        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        experimental = { ghost_text = { hl_group = "CmpGhostText" } },
      })

      -- Completion for "/" search
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })

      -- Completion for ":" commands
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources(
          { { name = "path" } },
          { { name = "cmdline" } }
        ),
        matching = { disallow_symbol_nonprefix_matching = false },
      })

      -- ── Diagnostics UI ──────────────────────────────────────────────────────
      vim.diagnostic.config({
        underline    = true,
        update_in_insert = false,
        severity_sort= true,
        float = { border = "rounded", source = "always" },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN]  = " ",
            [vim.diagnostic.severity.HINT]  = "󰠠 ",
            [vim.diagnostic.severity.INFO]  = " ",
          },
        },
        virtual_text = {
          spacing = 4,
          source  = "if_many",
          prefix  = "●",
        },
      })

      -- ── on_attach ───────────────────────────────────────────────────────────
      local on_attach = function(client, bufnr)
        -- Let conform/prettier handle formatting for JS/TS
        local no_fmt = { ts_ls = true, tailwindcss = true, html = true, jsonls = true }
        if no_fmt[client.name] then
          client.server_capabilities.documentFormattingProvider = false
        end

        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
        end

        -- Neovim 0.11 built-ins (don't redefine — causes which-key overlap warnings):
        --   grr = references, gra = code_action, grn = rename
        --   gri = implementation, grt = type_definition
        -- We only set mappings that Neovim 0.11 does NOT define by default:
        map("n", "K",          vim.lsp.buf.hover,       "Hover docs")
        map("n", "gd",         vim.lsp.buf.definition,  "Go to definition")
        map("n", "gD",         vim.lsp.buf.declaration, "Go to declaration")
        -- Keep <leader> versions for discoverability via which-key
        map("n", "<leader>cr", vim.lsp.buf.rename,      "Rename symbol")
        map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("v", "<leader>ca", vim.lsp.buf.code_action, "Code action (range)")
        map("n", "<leader>cf", function()
          vim.lsp.buf.format({ async = true })
        end, "Format (LSP)")
        map("n", "<leader>ci", vim.lsp.buf.implementation,  "Go to implementation")
        map("n", "<leader>cy", vim.lsp.buf.type_definition, "Type definition")
        map("n", "<leader>cs", vim.lsp.buf.document_symbol, "Document symbols")

        -- Show signature help on insert
        if client.server_capabilities.signatureHelpProvider then
          vim.api.nvim_create_autocmd("CursorHoldI", {
            buffer   = bufnr,
            callback = vim.lsp.buf.signature_help,
          })
        end
      end

      -- ── LSP server configs ──────────────────────────────────────────────────
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        on_attach    = on_attach,
        settings = {
          Lua = {
            runtime    = { version = "LuaJIT" },
            diagnostics= { globals = { "vim" } },
            workspace  = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
            telemetry  = { enable = false },
            format     = { enable = false },   -- use stylua via conform
          },
        },
      })

      vim.lsp.config("ts_ls", {
        capabilities = capabilities,
        on_attach    = on_attach,
        filetypes    = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
        settings = {
          javascript = { suggest = { completeFunctionCalls = true } },
          typescript = { suggest = { completeFunctionCalls = true } },
        },
      })

      vim.lsp.config("tailwindcss", {
        capabilities = capabilities,
        on_attach    = on_attach,
        filetypes    = {
          "astro", "html", "css", "scss",
          "javascript", "javascriptreact",
          "typescript", "typescriptreact",
        },
        root_markers = {
          "tailwind.config.js", "tailwind.config.cjs",
          "tailwind.config.ts", "postcss.config.js",
          "package.json", ".git",
        },
        settings = {
          tailwindCSS = {
            experimental = {
              classRegex = {
                "tw`([^`]*)",
                'tw="([^"]*)',
                "className\\s*[:=]\\s*[\"'`]([^\"'`]*)[\"'`]",
              },
            },
          },
        },
      })

      vim.lsp.config("cssls",   { capabilities = capabilities, on_attach = on_attach })
      vim.lsp.config("html",    { capabilities = capabilities, on_attach = on_attach })
      vim.lsp.config("jsonls",  { capabilities = capabilities, on_attach = on_attach })
      vim.lsp.config("bashls",  { capabilities = capabilities, on_attach = on_attach })
      vim.lsp.config("pyright", { capabilities = capabilities, on_attach = on_attach })

      vim.lsp.enable({
        "lua_ls", "ts_ls", "tailwindcss",
        "cssls", "html", "jsonls",
        "bashls", "pyright",
      })
    end,
  },
}
