-- ============================================================
--  autocmds.lua
-- ============================================================
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ── Highlight yanked text ─────────────────────────────────────────────────────
autocmd("TextYankPost", {
  group   = augroup("YankHighlight", { clear = true }),
  pattern = "*",
  callback = function()
    vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

-- ── Remove trailing whitespace on save ───────────────────────────────────────
autocmd("BufWritePre", {
  group   = augroup("TrimWhitespace", { clear = true }),
  pattern = "*",
  callback = function()
    local save = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(save)
  end,
})

-- ── Restore cursor position ───────────────────────────────────────────────────
autocmd("BufReadPost", {
  group   = augroup("RestoreCursor", { clear = true }),
  pattern = "*",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ── Auto-resize splits when window is resized ────────────────────────────────
autocmd("VimResized", {
  group   = augroup("ResizeSplits", { clear = true }),
  pattern = "*",
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- ── Per-filetype settings ─────────────────────────────────────────────────────
autocmd("FileType", {
  group   = augroup("FiletypeSettings", { clear = true }),
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap    = true
    vim.opt_local.spell   = true
    vim.opt_local.spelllang = "en_us"
  end,
})

autocmd("FileType", {
  group   = augroup("FiletypeIndent", { clear = true }),
  pattern = { "go" },
  callback = function()
    vim.opt_local.expandtab = false   -- Go uses real tabs
    vim.opt_local.tabstop   = 4
    vim.opt_local.shiftwidth= 4
  end,
})

-- ── Close certain windows with just 'q' ──────────────────────────────────────
autocmd("FileType", {
  group   = augroup("QuickClose", { clear = true }),
  pattern = {
    "help", "qf", "man", "lspinfo",
    "notify", "startuptime", "checkhealth",
    "DiffviewFiles",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
  end,
})

-- ── Auto-create missing directories on save ──────────────────────────────────
autocmd("BufWritePre", {
  group   = augroup("AutoMkdir", { clear = true }),
  pattern = "*",
  callback = function(event)
    if event.match:match("^%w%w+://") then return end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- ── Format on save (via conform, only if LSP is attached) ────────────────────
autocmd("BufWritePre", {
  group   = augroup("FormatOnSave", { clear = true }),
  pattern = {
    "*.js", "*.jsx", "*.ts", "*.tsx",
    "*.json", "*.css", "*.html", "*.lua",
  },
  callback = function()
    local ok, conform = pcall(require, "conform")
    if ok then
      conform.format({ async = false, lsp_fallback = true, timeout_ms = 800 })
    end
  end,
})
