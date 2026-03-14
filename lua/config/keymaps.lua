-- ============================================================
--  keymaps.lua — all non-plugin keymaps
-- ============================================================
local map = function(mode, lhs, rhs, opts)
  opts = vim.tbl_extend("force", { silent = true, noremap = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- ── General ───────────────────────────────────────────────────────────────────
map("n", "<Esc>",       "<cmd>nohlsearch<CR>",             { desc = "Clear search highlight" })
map("n", "<leader>w",   "<cmd>w<CR>",                      { desc = "Save" })
map("n", "<leader>q",   "<cmd>q<CR>",                      { desc = "Quit" })
map("n", "<leader>Q",   "<cmd>qa!<CR>",                    { desc = "Force quit all" })
map("n", "<leader>x",   "<cmd>bd<CR>",                     { desc = "Close buffer" })

-- ── Better movement ───────────────────────────────────────────────────────────
map("n", "j",  "gj",   { desc = "Down (visual line)" })
map("n", "k",  "gk",   { desc = "Up (visual line)" })
map("n", "H",  "^",    { desc = "Go to line start" })
map("n", "L",  "$",    { desc = "Go to line end" })

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
map("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Prev buffer" })
map("n", "<leader>bd","<cmd>bd<CR>",              { desc = "Delete buffer" })
map("n", "<leader>bo","<cmd>%bd|e#|bd#<CR>",      { desc = "Close all other buffers" })

-- ── Indenting that keeps selection ────────────────────────────────────────────
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- ── Move lines ────────────────────────────────────────────────────────────────
map("n", "<A-j>", "<cmd>m .+1<CR>==",         { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<CR>==",         { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv",         { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv",         { desc = "Move selection up" })

-- ── Better paste (don't yank replaced text) ───────────────────────────────────
map("v", "p",  '"_dP', { desc = "Paste without yank" })

-- ── Quickfix navigation ───────────────────────────────────────────────────────
map("n", "]q", "<cmd>cnext<CR>",  { desc = "Next quickfix" })
map("n", "[q", "<cmd>cprev<CR>",  { desc = "Prev quickfix" })
map("n", "<leader>cq", "<cmd>copen<CR>",  { desc = "Open quickfix" })

-- ── Diagnostics navigation ────────────────────────────────────────────────────
map("n", "]d", vim.diagnostic.goto_next,  { desc = "Next diagnostic" })
map("n", "[d", vim.diagnostic.goto_prev,  { desc = "Prev diagnostic" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Show diagnostic" })

-- ── Terminal ──────────────────────────────────────────────────────────────────
map("t", "<Esc><Esc>", "<C-\\><C-n>",  { desc = "Exit terminal mode" })

-- ── Config sync: pull git + sync plugins ──────────────────────────────────────
map("n", "<leader>pu", function()
  local out = vim.fn.system("cd ~/.config/nvim && git pull 2>&1")
  vim.notify(out, vim.log.levels.INFO, { title = "Config pull" })
  require("lazy").sync()
end, { desc = "Pull config + sync plugins" })

-- ── Splits ────────────────────────────────────────────────────────────────────
map("n", "<leader>sv", "<cmd>vsplit<CR>",  { desc = "Vertical split" })
map("n", "<leader>sh", "<cmd>split<CR>",   { desc = "Horizontal split" })

-- ── Fold shortcuts ────────────────────────────────────────────────────────────
map("n", "zR", function() require("ufo").openAllFolds() end,  { desc = "Open all folds" })
map("n", "zM", function() require("ufo").closeAllFolds() end, { desc = "Close all folds" })

-- ── Yank to end of line (consistent with D, C) ───────────────────────────────
map("n", "Y", "y$", { desc = "Yank to end of line" })
