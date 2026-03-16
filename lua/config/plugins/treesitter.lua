-- ============================================================
--  treesitter.lua
--
--  Keep this file. The previous error was caused by
--  build = ":TSUpdate" running during fresh install and
--  calling config() before the plugin was sourced.
--
--  This version has NO build step and loads on BufReadPre
--  which guarantees the plugin is fully sourced first.
--
--  After first install run :TSInstall all manually once.
--  To update parsers later: run :TSUpdate manually.
-- ============================================================
return {
  {
    "nvim-treesitter/nvim-treesitter",
    event  = { "BufReadPre", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "vim", "vimdoc", "query",
          "bash", "python", "json",
          "markdown", "markdown_inline",
          "javascript", "typescript", "tsx",
          "html", "css", "regex",
        },
        auto_install   = false,
        sync_install   = false,
        ignore_install = {},
        modules        = {},
        highlight = {
          enable                            = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable  = true,
          disable = { "javascript", "typescript", "tsx" },
        },
        incremental_selection = {
          enable  = true,
          keymaps = {
            init_selection    = "<CR>",
            node_incremental  = "<CR>",
            node_decremental  = "<BS>",
            scope_incremental = "<TAB>",
          },
        },
      })
    end,
  },
}
