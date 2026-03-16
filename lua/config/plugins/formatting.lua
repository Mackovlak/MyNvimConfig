-- ============================================================
--  formatting.lua — conform (formatting) + nvim-lint (linting)
-- ============================================================
return {

  -- ── Conform ─────────────────────────────────────────────────────────────────
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local conform = require("conform")

      conform.setup({
        formatters_by_ft = {
          javascript      = { "prettierd", "prettier", stop_after_first = true },
          typescript      = { "prettierd", "prettier", stop_after_first = true },
          javascriptreact = { "prettierd", "prettier", stop_after_first = true },
          typescriptreact = { "prettierd", "prettier", stop_after_first = true },
          json            = { "prettierd", "prettier", stop_after_first = true },
          jsonc           = { "prettierd", "prettier", stop_after_first = true },
          css             = { "prettierd", "prettier", stop_after_first = true },
          scss            = { "prettierd", "prettier", stop_after_first = true },
          html            = { "prettierd", "prettier", stop_after_first = true },
          markdown        = { "prettierd", "prettier", stop_after_first = true },
          yaml            = { "prettierd", "prettier", stop_after_first = true },
          lua             = { "stylua" },
          sh              = { "shfmt" },
          bash            = { "shfmt" },
          -- python/go: only add formatters if they're actually installed
          -- python = { "isort", "black" },  -- install via: pip install black isort
          -- go     = { "gofmt" },           -- install via: apt install golang
        },
        default_format_opts = { lsp_fallback = true },
      })

      -- Format whole buffer
      vim.keymap.set("n", "<leader>f", function()
        conform.format({ async = true, lsp_fallback = true })
      end, { desc = "Format buffer" })

      -- Format visual selection (fixed: read marks before exiting visual)
      vim.keymap.set("v", "<leader>f", function()
        local start_line = vim.fn.line("'<")
        local end_line   = vim.fn.line("'>")
        vim.api.nvim_feedkeys(
          vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false
        )
        conform.format({
          async = true, lsp_fallback = true,
          range = { start = { start_line, 0 }, ["end"] = { end_line, 0 } },
        })
      end, { desc = "Format selection" })
    end,
  },

  -- ── nvim-lint ────────────────────────────────────────────────────────────────
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      -- Only register linters that are actually installed.
      -- Attempting to run a missing linter causes ENOENT errors and lag.
      -- yamllint, flake8, hadolint etc are NOT installed by default on this VPS.
      -- Mason installs: eslint_d, shellcheck (via mason auto-install in lsp.lua)
      lint.linters_by_ft = {
        javascript      = { "eslint_d" },
        typescript      = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        sh              = { "shellcheck" },
        bash            = { "shellcheck" },
        -- yaml: removed yamllint — not installed, was causing ENOENT lag
        -- python: removed flake8 — not installed
        -- dockerfile: removed hadolint — not installed
      }

      -- Guard: only lint if the linter binary actually exists
      local function safe_lint()
        local ft = vim.bo.filetype
        local linters = lint.linters_by_ft[ft]
        if not linters then return end
        for _, linter in ipairs(linters) do
          if vim.fn.executable(linter) == 1 then
            lint.try_lint(linter)
          end
        end
      end

      local group = vim.api.nvim_create_augroup("NvimLint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
        group    = group,
        callback = safe_lint,
      })

      vim.keymap.set("n", "<leader>li", safe_lint, { desc = "Run linter" })
    end,
  },

}
