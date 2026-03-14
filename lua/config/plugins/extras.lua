-- ============================================================
--  extras.lua — session, testing, utilities, markdown
-- ============================================================
return {

  -- ── Session management ──────────────────────────────────────────────────────
  {
    "rmagatti/auto-session",
    lazy  = false,    -- must load early so it can restore
    opts  = {
      log_level              = "error",
      auto_save_enabled      = true,
      auto_restore_enabled   = true,
      -- Sessions stored in ~/.local/share/nvim/sessions/  (NOT in git)
      auto_session_root_dir  = vim.fn.stdpath("data") .. "/sessions/",
      bypass_session_save_file_types = {
        "NvimTree", "neo-tree", "dashboard", "alpha", "gitcommit",
      },
    },
    keys = {
      { "<leader>ss", "<cmd>SessionSave<CR>",    desc = "Save session" },
      { "<leader>sr", "<cmd>SessionRestore<CR>", desc = "Restore session" },
      { "<leader>sd", "<cmd>SessionDelete<CR>",  desc = "Delete session" },
      { "<leader>sl", "<cmd>Telescope session-lens<CR>", desc = "Sessions list" },
    },
  },

  -- ── Neotest — run tests inline ──────────────────────────────────────────────
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
    },
    keys = {
      { "<leader>tt", function() require("neotest").run.run() end,                  desc = "Run nearest test" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run file tests" },
      { "<leader>tT", function() require("neotest").run.run(vim.loop.cwd()) end,    desc = "Run all tests" },
      { "<leader>ts", function() require("neotest").summary.toggle() end,           desc = "Test summary" },
      { "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Test output" },
      { "<leader>tO", function() require("neotest").output_panel.toggle() end,     desc = "Output panel" },
      { "<leader>tS", function() require("neotest").run.stop() end,                desc = "Stop test" },
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({ dap = { justMyCode = false } }),
          require("neotest-jest")({
            jestCommand = "npm test --",
            jestConfigFile = "jest.config.ts",
            env = { CI = "true" },
          }),
          require("neotest-vitest"),
        },
      })
    end,
  },

  -- ── Todo comments — TODO/FIXME/HACK highlights + search ─────────────────────
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "BufReadPost",
    opts  = { signs = true },
    keys  = {
      { "]t",          function() require("todo-comments").jump_next() end, desc = "Next TODO" },
      { "[t",          function() require("todo-comments").jump_prev() end, desc = "Prev TODO" },
      { "<leader>ft",  "<cmd>TodoTelescope<CR>",  desc = "Find TODOs" },
      { "<leader>fT",  "<cmd>TodoTrouble<CR>",    desc = "TODOs (Trouble)" },
    },
  },

  -- ── Plenary (required by many plugins) ──────────────────────────────────────
  { "nvim-lua/plenary.nvim", lazy = true },

  -- ── Devicons ──────────────────────────────────────────────────────────────────
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- ── Markdown preview ─────────────────────────────────────────────────────────
  {
    "iamcco/markdown-preview.nvim",
    cmd   = { "MarkdownPreview", "MarkdownPreviewStop" },
    -- Use the pre-built release instead of building from source.
    -- This avoids the yarn.lock dirty-tree problem entirely.
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    init  = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft    = { "markdown" },
    keys  = {
      { "<leader>mp", "<cmd>MarkdownPreview<CR>",     desc = "Markdown preview" },
      { "<leader>ms", "<cmd>MarkdownPreviewStop<CR>", desc = "Stop preview" },
    },
  },

  -- ── Oil.nvim — edit filesystem like a buffer ─────────────────────────────────
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "-",          "<cmd>Oil<CR>",   desc = "Open parent directory (Oil)" },
      { "<leader>-",  function()
          require("oil").open(vim.fn.getcwd())
        end, desc = "Open cwd (Oil)" },
    },
    opts = {
      default_file_explorer = false,   -- keep NvimTree as default
      delete_to_trash       = true,
      view_options = { show_hidden = true },
    },
  },

  -- ── Persistence — alternative session (simpler) ────────────────────────────
  -- (commented out — using auto-session above; uncomment if you prefer this)
  -- {
  --   "folke/persistence.nvim",
  --   event = "BufReadPre",
  --   opts  = { dir = vim.fn.stdpath("data") .. "/sessions/" },
  --   keys  = {
  --     { "<leader>sr", function() require("persistence").load() end,            desc = "Restore session" },
  --     { "<leader>sl", function() require("persistence").load({ last = true }) end, desc = "Last session" },
  --     { "<leader>ss", function() require("persistence").save() end,            desc = "Save session" },
  --   },
  -- },

  -- ── Utility: mini.nvim modules ───────────────────────────────────────────────
  {
    "echasnovski/mini.nvim",
    version = false,
    event   = "VeryLazy",
    config  = function()
      -- mini.ai — extended text objects (a[, a{, af, etc.)
      require("mini.ai").setup({ n_lines = 500 })
      -- mini.pairs — auto pair brackets (lightweight alternative to autopairs)
      -- NOTE: disabled if you're using nvim-autopairs from lsp.lua
      -- require("mini.pairs").setup()
      -- mini.bufremove — smarter buffer deletion
      require("mini.bufremove").setup()
      vim.keymap.set("n", "<leader>bd", function()
        require("mini.bufremove").delete(0, false)
      end, { desc = "Delete buffer (mini)" })
      vim.keymap.set("n", "<leader>bD", function()
        require("mini.bufremove").delete(0, true)
      end, { desc = "Force delete buffer" })
    end,
  },

  -- ── Better quickfix ──────────────────────────────────────────────────────────
  {
    "kevinhwang91/nvim-bqf",
    ft   = "qf",
    opts = {
      preview = {
        winblend = 0,
        border   = "rounded",
      },
    },
  },

}
