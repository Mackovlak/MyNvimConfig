-- ============================================================
--  ui.lua — statusline, bufferline, notifications, dashboard
-- ============================================================
return {

  -- ── Bufferline ──────────────────────────────────────────────────────────────
  {
    "akinsho/bufferline.nvim",
    version      = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event        = "VeryLazy",
    opts = {
      options = {
        mode               = "buffers",
        numbers            = "none",
        diagnostics        = "nvim_lsp",
        separator_style    = "slant",
        show_buffer_close_icons = true,
        show_close_icon    = false,
        always_show_bufferline = true,
        offsets = {
          {
            filetype  = "NvimTree",
            text      = "  File Explorer",
            text_align= "left",
            separator = true,
          },
        },
      },
    },
  },

  -- ── Lualine ─────────────────────────────────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    event        = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme           = "tokyonight",
        globalstatus    = true,
        disabled_filetypes = { statusline = { "dashboard", "alpha" } },
        component_separators = { left = "", right = "" },
        section_separators  = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff",
          { "diagnostics", sources = { "nvim_lsp" } } },
        lualine_c = {
          { "filename", path = 1 },   -- relative path
        },
        lualine_x = {
          { -- show LSP server name
            function()
              local clients = vim.lsp.get_clients({ bufnr = 0 })
              if #clients == 0 then return "  no LSP" end
              local names = vim.tbl_map(function(c) return c.name end, clients)
              return "  " .. table.concat(names, ", ")
            end,
            color = { fg = "#6272a4" },
          },
          "encoding", "fileformat", "filetype",
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  -- ── Notifications — snacks.nvim notifier (no vim.str_utfindex deprecation) ──
  -- Replaces noice.nvim + nvim-notify which trigger vim.str_utfindex on Nvim 0.11
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy     = false,
    opts = {
      -- Minimal notifier — replaces nvim-notify popup
      notifier = {
        enabled = true,
        timeout = 3000,
        style   = "compact",
      },
      -- Better input/select UI
      input = { enabled = true },
      -- Improve vim.ui.select
      picker = { enabled = false },  -- we use telescope for this
    },
    config = function(_, opts)
      local snacks = require("snacks")
      snacks.setup(opts)
      -- Replace vim.notify globally
      vim.notify = snacks.notify
    end,
  },
  -- ── Dashboard — startup screen ──────────────────────────────────────────────
  {
    "nvimdev/dashboard-nvim",
    event        = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      theme = "doom",
      config = {
        header = {
          "",
          "  ██████╗  ██████╗ ██╗    ██╗███████╗██████╗ ",
          "  ██╔══██╗██╔═══██╗██║    ██║██╔════╝██╔══██╗",
          "  ██████╔╝██║   ██║██║ █╗ ██║█████╗  ██████╔╝",
          "  ██╔═══╝ ██║   ██║██║███╗██║██╔══╝  ██╔══██╗",
          "  ██║     ╚██████╔╝╚███╔███╔╝███████╗██║  ██║",
          "  ╚═╝      ╚═════╝  ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝",
          "",
        },
        center = {
          { icon = "  ", desc = "New file        ", key = "n", action = "enew" },
          { icon = "  ", desc = "Find file       ", key = "f", action = "Telescope find_files" },
          { icon = "  ", desc = "Recent files    ", key = "r", action = "Telescope oldfiles" },
          { icon = "  ", desc = "Find word       ", key = "g", action = "Telescope live_grep" },
          { icon = "  ", desc = "Restore session ", key = "s", action = "SessionRestore" },
          { icon = "󰒲  ", desc = "Lazy plugins    ", key = "l", action = "Lazy" },
          { icon = "  ", desc = "Quit            ", key = "q", action = "qa" },
        },
        footer = function()
          local stats = require("lazy").stats()
          return { "⚡ Loaded " .. stats.loaded .. "/" .. stats.count .. " plugins" }
        end,
      },
    },
  },

  -- ── Which-key — shows available keymaps ─────────────────────────────────────
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = {
        spelling   = { enabled = true, suggestions = 20 },
        -- IMPORTANT: disable registers preview — it reads the + clipboard
        -- register which triggers the OSC52 paste hang on every " keypress
        registers  = false,
        presets    = {
          operators    = false,  -- disable — conflicts with surround/comment
          motions      = false,
          text_objects = false,
          windows      = true,
          nav          = true,
          z            = true,
          g            = true,
        },
      },
      win = { border = "rounded" },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      -- Group labels
      wk.add({
        { "<leader>f",  group = "Find (Telescope)" },
        { "<leader>g",  group = "Git" },
        { "<leader>c",  group = "Code / LSP" },
        { "<leader>d",  group = "Diff" },
        { "<leader>h",  group = "Hunk / Gitsigns" },
        { "<leader>o",  group = "Octo (GitHub)" },
        { "<leader>s",  group = "Session" },
        { "<leader>t",  group = "Test" },
        { "<leader>u",  group = "UI toggles" },
        { "<leader>b",  group = "Buffer" },
      })
    end,
  },

  -- ── Indent guides ───────────────────────────────────────────────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "BufReadPost",
    main  = "ibl",
    opts  = {
      indent = { char = "│", highlight = "IblIndent" },
      scope  = { enabled = true, highlight = "IblScope" },
    },
  },

  -- ── Colorizer — show hex colors inline ──────────────────────────────────────
  {
    "NvChad/nvim-colorizer.lua",
    event = "BufReadPre",
    opts  = {
      user_default_options = {
        RGB      = true,
        RRGGBB   = true,
        names    = false,
        css      = true,
        tailwind = "both",
        mode     = "background",
      },
    },
  },

  -- ── Dressing — prettier vim.ui.input / vim.ui.select ────────────────────────
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },

  -- ── Trouble — pretty diagnostics / quickfix list ────────────────────────────
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd  = { "Trouble", "TroubleToggle" },
    opts = { use_diagnostic_signs = true },
    keys = {
      { "<leader>cx", "<cmd>Trouble diagnostics toggle<CR>",           desc = "Diagnostics (Trouble)" },
      { "<leader>cX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer diagnostics" },
      { "<leader>cs", "<cmd>Trouble symbols toggle<CR>",               desc = "Symbols (Trouble)" },
      { "<leader>cl", "<cmd>Trouble lsp toggle<CR>",                   desc = "LSP definitions (Trouble)" },
      { "<leader>cL", "<cmd>Trouble loclist toggle<CR>",               desc = "Location list" },
      { "<leader>cQ", "<cmd>Trouble qflist toggle<CR>",                desc = "Quickfix list" },
    },
  },

  -- ── Zen mode — focus writing ─────────────────────────────────────────────────
  {
    "folke/zen-mode.nvim",
    cmd  = "ZenMode",
    keys = { { "<leader>uz", "<cmd>ZenMode<CR>", desc = "Zen Mode" } },
    opts = {
      window = { width = 100 },
      plugins = {
        tmux       = { enabled = true },
        kitty      = { enabled = true, font = "+4" },
        alacritty  = { enabled = true, font = "14" },
      },
    },
  },

}
