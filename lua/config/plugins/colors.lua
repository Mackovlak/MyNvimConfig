-- ============================================================
--  colors.lua — Tokyo Night (dark, consistent on any terminal)
-- ============================================================
return {
  {
    "folke/tokyonight.nvim",
    lazy    = false,
    priority = 1000,       -- load first
    opts = {
      style          = "night",   -- night | storm | moon | day
      transparent    = false,
      terminal_colors= true,
      styles = {
        comments   = { italic = true },
        keywords   = { italic = true },
        functions  = {},
        variables  = {},
        sidebars   = "dark",
        floats     = "dark",
      },
      sidebars = { "qf", "help", "terminal", "NvimTree", "Trouble" },
      on_highlights = function(hl, c)
        -- Slightly brighter line numbers
        hl.LineNr       = { fg = c.dark5 }
        hl.CursorLineNr = { fg = c.orange, bold = true }
        -- Cleaner fold column
        hl.FoldColumn   = { fg = c.dark5, bg = c.none }
        hl.Folded       = { fg = c.blue7, bg = c.none }
      end,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd("colorscheme tokyonight")
    end,
  },
}
