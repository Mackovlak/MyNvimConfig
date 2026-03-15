-- ============================================================
--  treesitter.lua
--
--  The healthcheck error "install directory not in runtimepath"
--  means lazy.nvim installed the plugin but hasn't added its
--  parser directory to rtp yet when the config runs.
--
--  Fix: manually add the site dir to rtp BEFORE setup(), then
--  use the exact same simple config that worked before.
-- ============================================================
return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    -- lazy=false ensures it loads at startup, not on first buffer
    lazy  = false,
    config = function()
      -- Manually ensure the parser install dir is in rtp.
      -- This is what the healthcheck "not in runtimepath" error means.
      local parser_dir = vim.fn.stdpath("data") .. "/site"
      vim.opt.rtp:prepend(parser_dir)

      require("nvim-treesitter.configs").setup({
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
        ensure_installed = {
          "lua", "vim", "vimdoc", "query",
          "bash", "python", "json",
          "markdown", "markdown_inline",
          "javascript", "typescript", "tsx",
          "html", "css",
          "regex",   -- fixes noice warning
        },
        auto_install   = false,
        modules        = {},
        sync_install   = false,
        ignore_install = {},
      })
    end,
  },
}
