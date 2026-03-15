-- ============================================================
--  telescope.lua
-- ============================================================
return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    cmd  = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>",              desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>",               desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>",                 desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>",               desc = "Help tags" },
      { "<leader>fr", "<cmd>Telescope oldfiles<CR>",                desc = "Recent files" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>",    desc = "Symbols" },
      { "<leader>fS", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", desc = "Workspace symbols" },
      { "<leader>fd", "<cmd>Telescope diagnostics<CR>",             desc = "Diagnostics" },
      { "<leader>fk", "<cmd>Telescope keymaps<CR>",                 desc = "Keymaps" },
      { "<leader>fc", "<cmd>Telescope git_commits<CR>",             desc = "Git commits" },
      { "<leader>f/", "<cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "Fuzzy in buffer" },
      { "<leader>fw", function()
          require("telescope.builtin").grep_string({ word_match = "-w" })
        end, desc = "Word under cursor" },
    },
    config = function()
      local telescope = require("telescope")
      local actions   = require("telescope.actions")

      -- Ubuntu installs fd as "fdfind" — detect which one is available
      local fd_cmd
      if vim.fn.executable("fd") == 1 then
        fd_cmd = "fd"
      elseif vim.fn.executable("fdfind") == 1 then
        fd_cmd = "fdfind"
      end

      -- Build find_files command based on what's available
      local find_files_cmd = nil
      if fd_cmd then
        find_files_cmd = {
          fd_cmd, "--type", "f", "--strip-cwd-prefix",
          "--hidden", "--exclude", ".git",
        }
      end

      telescope.setup({
        defaults = {
          prompt_prefix   = "  ",
          selection_caret = " ",
          path_display    = { "smart" },
          layout_config   = {
            horizontal     = { preview_width = 0.55 },
            width          = 0.87,
            height         = 0.80,
            preview_cutoff = 120,
          },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<Esc>"] = actions.close,
            },
          },
          file_ignore_patterns = {
            "node_modules", "%.git/", "dist/", "build/",
            "%.lock", "package%-lock%.json",
          },
          -- rg for live_grep (always works — rg is installed)
          vimgrep_arguments = {
            "rg", "--color=never", "--no-heading", "--with-filename",
            "--line-number", "--column", "--smart-case", "--hidden",
            "--glob=!.git/",
          },
        },
        pickers = {
          find_files = {
            hidden       = true,
            -- Use fd/fdfind if available, otherwise fall back to Neovim's
            -- built-in file finder (no external dependency needed)
            find_command = find_files_cmd,
          },
          live_grep = {
            additional_args = { "--hidden", "--glob=!.git/" },
          },
        },
        extensions = {
          fzf = {
            fuzzy                   = true,
            override_generic_sorter = true,
            override_file_sorter    = true,
            case_mode               = "smart_case",
          },
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
      })

      -- Load extensions (wrapped in pcall so a build failure doesn't break startup)
      local function load_ext(name)
        local ok, err = pcall(telescope.load_extension, name)
        if not ok then
          vim.notify("telescope-" .. name .. ": " .. err, vim.log.levels.WARN)
        end
      end

      load_ext("fzf")
      load_ext("ui-select")
    end,
  },
}
