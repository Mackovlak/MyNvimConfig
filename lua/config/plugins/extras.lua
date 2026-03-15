-- ============================================================
--  extras.lua — sessions, todos, utilities
--  (kept lean: removed markdown-preview, neotest, auto-save,
--   peek — add them back once core is stable)
-- ============================================================
return {

  -- ── Session management ──────────────────────────────────────────────────────
  {
    "rmagatti/auto-session",
    lazy  = false,
    opts  = {
      log_level          = "error",
      auto_save          = true,
      auto_restore       = true,
      root_dir           = vim.fn.stdpath("data") .. "/sessions/",
      bypass_save_filetypes = {
        "NvimTree", "neo-tree", "dashboard", "alpha", "gitcommit",
      },
    },
    keys = {
      { "<leader>ss", "<cmd>SessionSave<CR>",    desc = "Save session" },
      { "<leader>sr", "<cmd>SessionRestore<CR>", desc = "Restore session" },
      { "<leader>sd", "<cmd>SessionDelete<CR>",  desc = "Delete session" },
    },
  },

  -- ── Todo comments ───────────────────────────────────────────────────────────
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "BufReadPost",
    opts  = { signs = true },
    keys  = {
      { "]t",         function() require("todo-comments").jump_next() end, desc = "Next TODO" },
      { "[t",         function() require("todo-comments").jump_prev() end, desc = "Prev TODO" },
      { "<leader>ft", "<cmd>TodoTelescope<CR>", desc = "Find TODOs" },
    },
  },

  -- ── Plenary ─────────────────────────────────────────────────────────────────
  { "nvim-lua/plenary.nvim", lazy = true },

  -- ── Devicons ─────────────────────────────────────────────────────────────────
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- ── Oil.nvim — edit filesystem like a buffer ─────────────────────────────────
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "-", "<cmd>Oil<CR>", desc = "Open parent dir (Oil)" },
    },
    opts = {
      default_file_explorer = false,
      delete_to_trash       = true,
      view_options          = { show_hidden = true },
    },
  },

  -- ── mini.nvim — text objects + smart buffer delete ───────────────────────────
  {
    "echasnovski/mini.nvim",
    version = false,
    event   = "VeryLazy",
    config  = function()
      require("mini.ai").setup({ n_lines = 500 })
      require("mini.bufremove").setup()
      vim.keymap.set("n", "<leader>bd", function()
        require("mini.bufremove").delete(0, false)
      end, { desc = "Delete buffer" })
      vim.keymap.set("n", "<leader>bD", function()
        require("mini.bufremove").delete(0, true)
      end, { desc = "Force delete buffer" })
    end,
  },

  -- ── Better quickfix ──────────────────────────────────────────────────────────
  {
    "kevinhwang91/nvim-bqf",
    ft   = "qf",
    opts = { preview = { border = "rounded" } },
  },

}
