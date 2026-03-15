-- ============================================================
--  treesitter.lua — Neovim 0.11 compatible
--
--  The old require("nvim-treesitter.configs").setup() call fails
--  when lazy.nvim hasn't finished adding the plugin to rtp yet.
--
--  Fix: defer setup until after "LazyDone" fires so the plugin's
--  runtime path is guaranteed to be available.
-- ============================================================
return {
  {
    "nvim-treesitter/nvim-treesitter",
    build    = ":TSUpdate",
    lazy     = false,
    priority = 900,
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      -- Defer until lazy has finished loading everything,
      -- so the plugin's rtp entry exists before we require it.
      vim.api.nvim_create_autocmd("User", {
        pattern  = "LazyDone",
        once     = true,
        callback = function()
          local ok, configs = pcall(require, "nvim-treesitter.configs")
          if not ok then
            vim.notify(
              "nvim-treesitter not ready — run :Lazy sync then restart nvim",
              vim.log.levels.WARN,
              { title = "treesitter" }
            )
            return
          end

          configs.setup({
            ensure_installed = {
              "bash",       "c",          "cpp",         "css",
              "diff",       "dockerfile", "html",        "javascript",
              "json",       "json5",      "lua",         "luadoc",
              "markdown",   "markdown_inline",
              "python",     "query",      "regex",       "tsx",
              "typescript", "vim",        "vimdoc",      "yaml",
            },
            -- auto_install: installs missing parsers when you open a file
            auto_install   = true,
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

            -- Changed <CR> → <C-space> to avoid conflicts with cmp confirm
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
                  ["ai"] = { query = "@conditional.outer", desc = "Outer if"   },
                  ["ii"] = { query = "@conditional.inner", desc = "Inner if"   },
                  ["al"] = { query = "@loop.outer",     desc = "Outer loop"    },
                  ["il"] = { query = "@loop.inner",     desc = "Inner loop"    },
                },
              },
              move = {
                enable    = true,
                set_jumps = true,
                goto_next_start     = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
                goto_next_end       = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
                goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
                goto_previous_end   = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
              },
              swap = {
                enable        = true,
                swap_next     = { ["<leader>sp"] = "@parameter.inner" },
                swap_previous = { ["<leader>sP"] = "@parameter.inner" },
              },
            },
          })
        end,
      })
    end,
  },
}
