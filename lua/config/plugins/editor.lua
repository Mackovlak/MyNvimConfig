-- ============================================================
--  editor.lua — file tree, navigation, folds, terminal, search
-- ============================================================
return {

  -- ── NvimTree — file explorer ────────────────────────────────────────────────
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>e",  "<cmd>NvimTreeToggle<CR>",   desc = "Toggle file tree" },
      { "<leader>E",  "<cmd>NvimTreeFindFile<CR>", desc = "Reveal current file" },
    },
    opts = {
      view = { width = 32, side = "left" },
      sort = { sorter = "case_sensitive" },
      renderer = {
        group_empty = true,
        highlight_git = true,
        icons = {
          show = { git = true, file = true, folder = true },
        },
      },
      filters = {
        dotfiles = false,     -- show dotfiles
        custom   = { "^.git$", "node_modules", ".DS_Store" },
      },
      git = { enable = true, ignore = false },
      actions = {
        open_file = { quit_on_open = false },
      },
    },
  },

  -- ── Harpoon 2 — per-project file bookmarks ──────────────────────────────────
  {
    "ThePrimeagen/harpoon",
    branch       = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ha", function() require("harpoon"):list():add() end,    desc = "Harpoon add file" },
      { "<leader>hm", function() local hp = require("harpoon")
          hp.ui:toggle_quick_menu(hp:list()) end,                         desc = "Harpoon menu" },
      { "<leader>1",  function() require("harpoon"):list():select(1) end, desc = "Harpoon 1" },
      { "<leader>2",  function() require("harpoon"):list():select(2) end, desc = "Harpoon 2" },
      { "<leader>3",  function() require("harpoon"):list():select(3) end, desc = "Harpoon 3" },
      { "<leader>4",  function() require("harpoon"):list():select(4) end, desc = "Harpoon 4" },
      { "<leader>5",  function() require("harpoon"):list():select(5) end, desc = "Harpoon 5" },
    },
    config = function()
      require("harpoon"):setup()
    end,
  },

  -- ── nvim-ufo — prettier folds with count ────────────────────────────────────
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufReadPost",
    opts  = {
      provider_selector = function(_, filetype, _)
        -- Use LSP for these, treesitter for rest
        local lsp_filetypes = { "typescript", "javascript", "lua", "python", "go" }
        for _, ft in ipairs(lsp_filetypes) do
          if filetype == ft then return { "lsp", "treesitter" } end
        end
        return { "treesitter", "indent" }
      end,
      -- Show number of folded lines
      fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = ("  %d lines"):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText  = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            table.insert(newVirtText, { chunkText, chunk[2] })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, "MoreMsg" })
        return newVirtText
      end,
    },
  },

  -- ── Toggleterm — floating/split terminal ────────────────────────────────────
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { [[<C-\>]],    desc = "Toggle terminal" },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<CR>",      desc = "Float terminal" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "Horizontal terminal" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>",   desc = "Vertical terminal" },
    },
    opts = {
      size = function(term)
        if term.direction == "horizontal" then return 16
        elseif term.direction == "vertical" then return math.floor(vim.o.columns * 0.4)
        end
      end,
      open_mapping   = [[<C-\>]],
      direction      = "float",
      close_on_exit  = true,
      float_opts     = { border = "curved" },
    },
  },

  -- ── Spectre — project-wide find & replace ───────────────────────────────────
  {
    "nvim-pack/nvim-spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>sr",  function() require("spectre").open() end,             desc = "Spectre (replace)" },
      { "<leader>sR",  function() require("spectre").open_visual() end,      desc = "Spectre (visual)",   mode = "v" },
      { "<leader>sf",  function() require("spectre").open_file_search() end, desc = "Spectre (file)" },
    },
  },

  -- ── Flash — enhanced f/t + search labels ────────────────────────────────────
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts  = { modes = { search = { enabled = false } } },
    keys  = {
      { "s",     function() require("flash").jump() end,       desc = "Flash jump",        mode = { "n", "x", "o" } },
      { "S",     function() require("flash").treesitter() end, desc = "Flash treesitter",  mode = { "n", "o", "x" } },
      { "r",     function() require("flash").remote() end,     desc = "Flash remote",      mode = "o" },
      { "<C-s>", function() require("flash").toggle() end,     desc = "Toggle flash search",mode = { "c" } },
    },
  },

  -- ── Surround — add/change/delete surrounds ──────────────────────────────────
  {
    "kylechui/nvim-surround",
    version = "*",
    event   = "VeryLazy",
    opts    = {},
  },

  -- ── Comment.nvim ────────────────────────────────────────────────────────────
  {
    "numToStr/Comment.nvim",
    event = "BufReadPost",
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    config = function()
      require("ts_context_commentstring").setup({ enable_autocmd = false })
      require("Comment").setup({
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      })
    end,
  },

  -- ── Inc-rename — live preview of rename ─────────────────────────────────────
  {
    "smjonas/inc-rename.nvim",
    cmd  = "IncRename",
    keys = {
      { "<leader>rn", function()
          return ":IncRename " .. vim.fn.expand("<cword>")
        end, desc = "Rename (live preview)", expr = true },
    },
    opts = {},
  },

  -- ── Auto-save ───────────────────────────────────────────────────────────────
  {
    "okuuva/auto-save.nvim",
    event = { "InsertLeave", "TextChanged" },
    opts  = {
      enabled          = true,
      trigger_events   = {
        immediate_save = { "BufLeave", "FocusLost" },
        defer_save     = { "InsertLeave", "TextChanged" },
        cancel_deferred_save = { "InsertEnter" },
      },
      debounce_delay   = 2000,
      -- Don't save these
      condition        = function(buf)
        local fn   = vim.fn
        local utils = require("auto-save.utils.data")
        if fn.getbufvar(buf, "&modifiable") == 1 and
           utils.not_in(fn.getbufvar(buf, "&filetype"), { "gitcommit", "oil" }) then
          return true
        end
        return false
      end,
    },
    keys = {
      { "<leader>ua", "<cmd>ASToggle<CR>", desc = "Toggle auto-save" },
    },
  },

}
