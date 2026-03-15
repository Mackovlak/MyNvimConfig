-- ============================================================
--  treesitter.lua — Neovim 0.11
--
--  Root cause of "configs not found": lazy.nvim sets up rtp
--  entries AFTER all plugin config() functions have been called
--  for non-lazy plugins. So even priority=900 + lazy=false
--  doesn't guarantee the plugin files are in rtp when config()
--  runs synchronously.
--
--  Fix: wrap the require inside vim.schedule() which defers it
--  to the next event loop tick — by then lazy has finished
--  adding everything to rtp.
-- ============================================================
return {
  {
    "nvim-treesitter/nvim-treesitter",
    build        = ":TSUpdate",
    lazy         = false,
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    config = function()
      vim.schedule(function()
        local ok, configs = pcall(require, "nvim-treesitter.configs")
        if not ok then
          vim.notify(
            "nvim-treesitter not installed yet.\nRun :Lazy sync then restart nvim.",
            vim.log.levels.WARN, { title = "treesitter" }
          )
          return
        end

        ---@diagnostic disable-next-line: missing-fields
        configs.setup({
          ensure_installed = {
            "bash",       "c",          "css",
            "dockerfile", "html",       "javascript",
            "json",       "lua",        "markdown",
            "markdown_inline",          "python",
            "query",      "regex",      "tsx",
            "typescript", "vim",        "vimdoc",
            "yaml",
          },
          auto_install   = true,   -- install missing parsers on filetype open
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

          -- <C-space> to expand selection (was <CR> which conflicted with cmp)
          incremental_selection = {
            enable  = true,
            keymaps = {
              init_selection    = "<C-space>",
              node_incremental  = "<C-space>",
              node_decremental  = "<bs>",
              scope_incremental = false,
            },
          },

          textobjects = {
            select = {
              enable    = true,
              lookahead = true,
              keymaps   = {
                ["af"] = { query = "@function.outer", desc = "Outer function" },
                ["if"] = { query = "@function.inner", desc = "Inner function" },
                ["ac"] = { query = "@class.outer",    desc = "Outer class"    },
                ["ic"] = { query = "@class.inner",    desc = "Inner class"    },
                ["aa"] = { query = "@parameter.outer",desc = "Outer argument" },
                ["ia"] = { query = "@parameter.inner",desc = "Inner argument" },
              },
            },
            move = {
              enable    = true,
              set_jumps = true,
              goto_next_start     = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
              goto_next_end       = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
              goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
            },
          },
        })
      end)
    end,
  },
}
