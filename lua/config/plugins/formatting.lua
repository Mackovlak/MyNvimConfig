-- ============================================================
--  formatting.lua — conform + nvim-lint
-- ============================================================
return {

  -- ── Conform — formatting ────────────────────────────────────────────────────
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
          python          = { "isort", "black" },
          go              = { "gofmt" },
          sh              = { "shfmt" },
          bash            = { "shfmt" },
        },
        -- Fallback for unlisted filetypes
        default_format_opts = { lsp_fallback = true },
      })

      -- ── Normal mode: format whole buffer ──────────────────────────────────
      vim.keymap.set("n", "<leader>f", function()
        conform.format({ async = true, lsp_fallback = true })
      end, { desc = "Format buffer" })

      -- ── Visual mode: format only selected lines (FIXED) ───────────────────
      vim.keymap.set("v", "<leader>f", function()
        local start_line = vim.fn.line("'<")
        local end_line   = vim.fn.line("'>")
        -- Exit visual mode before formatting
        vim.api.nvim_feedkeys(
          vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false
        )
        conform.format({
          async        = true,
          lsp_fallback = true,
          range = {
            start = { start_line, 0 },
            ["end"] = { end_line, 0 },
          },
        })
      end, { desc = "Format selection" })

      -- ── Format on paste (wraps p / P) ─────────────────────────────────────
      local function paste_and_format(paste_cmd)
        return function()
          local before = vim.fn.line(".")
          vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes(paste_cmd, true, false, true), "x", false
          )
          vim.schedule(function()
            local after = vim.fn.line(".")
            conform.format({
              async        = false,
              lsp_fallback = true,
              range = {
                start    = { math.min(before, after), 0 },
                ["end"]  = { math.max(before, after), 0 },
              },
            })
          end)
        end
      end

      vim.keymap.set("n", "p", paste_and_format("p"), { desc = "Paste + format" })
      vim.keymap.set("n", "P", paste_and_format("P"), { desc = "Paste above + format" })
    end,
  },

  -- ── nvim-lint — async linting ────────────────────────────────────────────────
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        javascript      = { "eslint_d" },
        typescript      = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        python          = { "flake8" },
        sh              = { "shellcheck" },
        bash            = { "shellcheck" },
        dockerfile      = { "hadolint" },
        yaml            = { "yamllint" },
      }

      -- Trigger linting on relevant events
      local lint_augroup = vim.api.nvim_create_augroup("NvimLint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group    = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })

      vim.keymap.set("n", "<leader>li", function()
        lint.try_lint()
      end, { desc = "Run linter" })
    end,
  },

}
