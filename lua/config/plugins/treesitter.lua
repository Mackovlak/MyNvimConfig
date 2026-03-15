-- ============================================================
--  treesitter.lua
--
--  The persistent "configs not found" error happens because
--  lazy.nvim's internal loader calls require(main) at a point
--  where the plugin's lua/ directory isn't guaranteed to be
--  in the Lua package path yet — regardless of lazy=false,
--  main+opts, vim.schedule, or LazyDone autocmds.
--
--  The only approach that is 100% reliable:
--    1. Don't use lazy=false — let lazy load it on BufReadPre
--    2. Use a plain config() function (no main field)
--    3. nvim-treesitter registers itself in package.preload
--       when its files are sourced — by BufReadPre that is done.
--
--  This is how the vast majority of nvim-treesitter configs
--  in the wild work without issues.
-- ============================================================
return {
  {
    "nvim-treesitter/nvim-treesitter",
    build  = ":TSUpdate",
    -- Load on first buffer read — by this point lazy has fully
    -- sourced the plugin and package.preload is populated
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
