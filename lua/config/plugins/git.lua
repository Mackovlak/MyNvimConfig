-- ============================================================
--  git.lua — gitsigns, diffview, neogit, octo, fugitive
-- ============================================================
return {

  -- ── Gitsigns — inline blame + hunk actions ──────────────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts  = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text         = true,
        virt_text_pos     = "eol",
        delay             = 800,
        ignore_whitespace = true,
      },
      on_attach = function(bufnr)
        local gs  = package.loaded.gitsigns
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, silent = true, desc = desc })
        end

        -- Navigation
        map("n", "]h", function()
          if vim.wo.diff then return "]h" end
          vim.schedule(gs.next_hunk)
        end, "Next hunk")
        map("n", "[h", function()
          if vim.wo.diff then return "[h" end
          vim.schedule(gs.prev_hunk)
        end, "Prev hunk")

        -- Actions
        map("n", "<leader>hs",  gs.stage_hunk,               "Stage hunk")
        map("n", "<leader>hr",  gs.reset_hunk,               "Reset hunk")
        map("v", "<leader>hs",  function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage hunk (range)")
        map("v", "<leader>hr",  function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset hunk (range)")
        map("n", "<leader>hS",  gs.stage_buffer,             "Stage buffer")
        map("n", "<leader>hu",  gs.undo_stage_hunk,          "Undo stage hunk")
        map("n", "<leader>hR",  gs.reset_buffer,             "Reset buffer")
        map("n", "<leader>hp",  gs.preview_hunk,             "Preview hunk")
        map("n", "<leader>hb",  function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>hd",  gs.diffthis,                 "Diff this")
        map("n", "<leader>hD",  function() gs.diffthis("~") end, "Diff this ~")
        map("n", "<leader>htb", gs.toggle_current_line_blame, "Toggle blame")
        map("n", "<leader>htd", gs.toggle_deleted,           "Toggle deleted")

        -- Text objects: ih = inner hunk
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
      end,
    },
  },

  -- ── Diffview — side-by-side diffs + file history ────────────────────────────
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd  = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    keys = {
      { "<leader>dv",  "<cmd>DiffviewOpen<CR>",               desc = "Diff vs HEAD" },
      { "<leader>dc",  "<cmd>DiffviewClose<CR>",              desc = "Close diffview" },
      { "<leader>dh",  "<cmd>DiffviewFileHistory %<CR>",      desc = "File history" },
      { "<leader>dH",  "<cmd>DiffviewFileHistory<CR>",        desc = "Project history" },
    },
    opts = { enhanced_diff_hl = true },
  },

  -- ── Neogit — Magit-like git interface ───────────────────────────────────────
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd  = "Neogit",
    keys = {
      { "<leader>gs", function()
          require("neogit").open({ kind = "tab" })
        end, desc = "Neogit (Source Control)" },
    },
    opts = {
      disable_hint             = false,
      disable_commit_confirmation = false,
      integrations             = { diffview = true, telescope = true },
    },
  },

  -- ── Fugitive — git commands from Neovim ─────────────────────────────────────
  {
    "tpope/vim-fugitive",
    cmd  = { "Git", "Gdiffsplit", "Gblame", "Gclog" },
    keys = {
      { "<leader>gd",  "<cmd>Gdiffsplit<CR>",  desc = "Git diff split" },
      { "<leader>gb",  "<cmd>Git blame<CR>",   desc = "Git blame" },
      { "<leader>gl",  "<cmd>Gclog<CR>",       desc = "Git log" },
    },
  },

  -- ── Octo — GitHub PRs + issues inside Neovim ────────────────────────────────
  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    cmd  = "Octo",
    keys = {
      { "<leader>opl", "<cmd>Octo pr list<CR>",              desc = "PR list" },
      { "<leader>opc", ":Octo pr checkout ",                 desc = "PR checkout",   silent = false },
      { "<leader>ors", "<cmd>Octo review start<CR>",         desc = "Review start" },
      { "<leader>ora", "<cmd>Octo review submit<CR>",        desc = "Review submit" },
      { "<leader>opm", "<cmd>Octo pr merge<CR>",             desc = "PR merge" },
      { "<leader>oil", "<cmd>Octo issue list<CR>",           desc = "Issue list" },
      { "<leader>oic", "<cmd>Octo issue create<CR>",         desc = "Issue create" },
    },
    config = function()
      require("octo").setup({
        default_merge_method = "squash",
        picker               = "telescope",
      })
    end,
  },

}
