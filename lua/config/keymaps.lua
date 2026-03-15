-- ============================================================
--  keymaps.lua — all non-plugin keymaps
--
--  Conflicts avoided:
--  • gr/gra/grn/grr/gri/grt  — reserved by Neovim 0.11 built-in LSP
--  • gc/gcc/gb/gbc            — reserved by Comment.nvim
--  • ys/yS/cs/ds              — reserved by nvim-surround
--  • s/S                      — reserved by flash.nvim
--  All LSP mappings are defined in lsp.lua on_attach (buffer-local)
-- ============================================================
local map = function(mode, lhs, rhs, opts)
  opts = vim.tbl_extend("force", { silent = true, noremap = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- ── General ───────────────────────────────────────────────────────────────────
map("n", "<Esc>",      "<cmd>nohlsearch<CR>",    { desc = "Clear search highlight" })
map("n", "<leader>w",  "<cmd>w<CR>",             { desc = "Save" })
map("n", "<leader>q",  "<cmd>q<CR>",             { desc = "Quit" })
map("n", "<leader>Q",  "<cmd>qa!<CR>",           { desc = "Force quit all" })

-- ── Better movement ───────────────────────────────────────────────────────────
map("n", "j",  "gj",   { desc = "Down (visual line)" })
map("n", "k",  "gk",   { desc = "Up (visual line)" })
map("n", "H",  "^",    { desc = "Line start" })
map("n", "L",  "$",    { desc = "Line end" })
map("n", "Y",  "y$",   { desc = "Yank to end of line" })

-- ── Window navigation ─────────────────────────────────────────────────────────
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- ── Window resize ─────────────────────────────────────────────────────────────
map("n", "<C-Up>",    "<cmd>resize +2<CR>",          { desc = "Increase height" })
map("n", "<C-Down>",  "<cmd>resize -2<CR>",          { desc = "Decrease height" })
map("n", "<C-Left>",  "<cmd>vertical resize -2<CR>", { desc = "Decrease width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase width" })

-- ── Buffer navigation ─────────────────────────────────────────────────────────
-- Note: <S-l> and <S-h> are set here; bufferline also sets them.
-- We keep them here as fallback in case bufferline isn't loaded.
map("n", "<S-l>", "<cmd>bnext<CR>",              { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>bprev<CR>",              { desc = "Prev buffer" })
map("n", "<leader>x", "<cmd>bd<CR>",             { desc = "Close buffer" })
map("n", "<leader>bo", "<cmd>%bd|e#|bd#<CR>",    { desc = "Close all other buffers" })

-- ── Indenting keeps selection ─────────────────────────────────────────────────
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- ── Move lines ────────────────────────────────────────────────────────────────
map("n", "<A-j>", "<cmd>m .+1<CR>==",    { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<CR>==",    { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv",   { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv",   { desc = "Move selection up" })

-- ── Better paste in visual (don't yank replaced text) ────────────────────────
map("v", "p",  '"_dP', { desc = "Paste without yank" })

-- ── Quickfix ──────────────────────────────────────────────────────────────────
map("n", "]q", "<cmd>cnext<CR>", { desc = "Next quickfix" })
map("n", "[q", "<cmd>cprev<CR>", { desc = "Prev quickfix" })

-- ── Diagnostics (use <leader>c prefix to avoid conflicts) ────────────────────
-- Note: ]d and [d are Neovim 0.11 built-ins for diagnostic navigation
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Show diagnostic" })

-- ── Splits ────────────────────────────────────────────────────────────────────
map("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Vertical split" })
map("n", "<leader>sh", "<cmd>split<CR>",  { desc = "Horizontal split" })

-- ── Terminal ──────────────────────────────────────────────────────────────────
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- ── Config sync ───────────────────────────────────────────────────────────────
map("n", "<leader>pu", function()
  local out = vim.fn.system("cd ~/.config/nvim && git pull 2>&1")
  vim.notify(out, vim.log.levels.INFO, { title = "Config pull" })
  require("lazy").sync()
end, { desc = "Pull config + sync plugins" })

-- ── UI toggles ────────────────────────────────────────────────────────────────
map("n", "<leader>uw", "<cmd>set wrap!<CR>",        { desc = "Toggle wrap" })
map("n", "<leader>un", "<cmd>set number!<CR>",       { desc = "Toggle line numbers" })
map("n", "<leader>ur", "<cmd>set relativenumber!<CR>", { desc = "Toggle relative numbers" })
