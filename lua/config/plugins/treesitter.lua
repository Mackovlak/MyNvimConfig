-- ============================================================
--  treesitter.lua
-- ============================================================
return {
  {
    "nvim-treesitter/nvim-treesitter",
    build        = ":TSUpdate",
    -- Load early (not lazily on event) so other plugins that depend on
    -- treesitter (LSP folds, autotag, context commentstring) can find it.
    lazy         = false,
    priority     = 900,
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "bash",   "c",         "cpp",   "css",
          "diff",   "dockerfile","go",    "graphql",
          "html",   "http",      "java",  "javascript",
          "json",   "json5",     "lua",   "luadoc",
          "make",   "markdown",  "markdown_inline",
          "python", "query",     "regex", "rust",
          "sql",    "toml",      "tsx",   "typescript",
          "vim",    "vimdoc",    "xml",   "yaml",
        },
        auto_install = false,
        highlight    = { enable = true, additional_vim_regex_highlighting = false },
        indent       = {
          enable  = true,
          disable = { "javascript", "typescript", "tsx" },  -- let prettier handle
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
        -- ── Text objects ──────────────────────────────────────────────────────
        textobjects = {
          select = {
            enable    = true,
            lookahead = true,
            keymaps = {
              ["af"] = { query = "@function.outer", desc = "Outer function" },
              ["if"] = { query = "@function.inner", desc = "Inner function" },
              ["ac"] = { query = "@class.outer",    desc = "Outer class" },
              ["ic"] = { query = "@class.inner",    desc = "Inner class" },
              ["aa"] = { query = "@parameter.outer",desc = "Outer argument" },
              ["ia"] = { query = "@parameter.inner",desc = "Inner argument" },
              ["ai"] = { query = "@conditional.outer", desc = "Outer if" },
              ["ii"] = { query = "@conditional.inner", desc = "Inner if" },
              ["al"] = { query = "@loop.outer",     desc = "Outer loop" },
              ["il"] = { query = "@loop.inner",     desc = "Inner loop" },
            },
          },
          move = {
            enable              = true,
            set_jumps           = true,
            goto_next_start     = {
              ["]f"] = "@function.outer",
              ["]c"] = "@class.outer",
            },
            goto_next_end       = {
              ["]F"] = "@function.outer",
              ["]C"] = "@class.outer",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
            },
          },
          swap = {
            enable = true,
            swap_next     = { ["<leader>sp"] = "@parameter.inner" },
            swap_previous = { ["<leader>sP"] = "@parameter.inner" },
          },
        },
        modules      = {},
        sync_install = false,
        ignore_install = {},
      })
    end,
  },
}
