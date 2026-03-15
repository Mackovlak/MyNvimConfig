-- ============================================================
--  treesitter.lua
--
--  Why configs keeps failing:
--  lazy=false means "load at startup" but lazy's load sequence is:
--    1. Parse all plugin specs (config functions are NOT called yet)
--    2. Add ALL plugins to rtp at once
--    3. Source each plugin's runtime files
--    4. THEN call config() functions
--
--  So config() should work — UNLESS the plugin isn't actually
--  installed yet (first launch) or the lazy cache is stale.
--
--  The real fix: use `opts` instead of `config = function()`.
--  When you use `opts`, lazy calls require(main).setup(opts)
--  itself, AFTER properly sourcing the plugin. This is the
--  idiomatic lazy.nvim way for plugins that have a .setup().
-- ============================================================
return {
  {
    "nvim-treesitter/nvim-treesitter",
    build   = ":TSUpdate",
    lazy    = false,
    -- Using `main` + `opts` is the correct lazy.nvim pattern.
    -- lazy handles the require() itself after the plugin is sourced.
    main    = "nvim-treesitter.configs",
    opts    = {
      ensure_installed = {
        "lua",  "vim",  "vimdoc",  "query",
        "bash", "python", "json",
        "markdown", "markdown_inline",
        "javascript", "typescript", "tsx",
        "html", "css", "regex",
      },
      auto_install   = false,
      sync_install   = false,
      ignore_install = {},
      modules        = {},

      highlight = { enable = true },

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
    },
  },
}
