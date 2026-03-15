-- ============================================================
--  options.lua
-- ============================================================
local opt = vim.opt
local o   = vim.o

-- ── UI ────────────────────────────────────────────────────────────────────────
opt.number         = true
opt.relativenumber = true
opt.cursorline     = true
opt.signcolumn     = "yes"        -- always show, prevents layout shift
opt.colorcolumn    = "100"        -- visual line limit
opt.scrolloff      = 8            -- keep 8 lines above/below cursor
opt.sidescrolloff  = 8
opt.termguicolors  = true
opt.showmode       = false        -- lualine shows this already
opt.cmdheight      = 1
opt.pumheight      = 12           -- max completion popup items
opt.splitright     = true
opt.splitbelow     = true
opt.laststatus     = 3            -- global statusline (single bar)
opt.winbar         = "%=%m %f"    -- file path in winbar

-- ── Indentation ───────────────────────────────────────────────────────────────
opt.expandtab   = true            -- tabs → spaces
opt.tabstop     = 2
opt.shiftwidth  = 2
opt.softtabstop = 2
opt.smartindent = true
opt.breakindent = true

-- ── Search ────────────────────────────────────────────────────────────────────
opt.ignorecase = true
opt.smartcase  = true
opt.hlsearch   = true
opt.incsearch  = true

-- ── Files & encoding ──────────────────────────────────────────────────────────
opt.encoding    = "utf-8"
opt.fileencoding= "utf-8"
opt.backup      = false
opt.swapfile    = false
opt.undofile    = true            -- persistent undo across sessions
opt.undodir     = vim.fn.stdpath("data") .. "/undodir"

-- ── Performance ───────────────────────────────────────────────────────────────
opt.updatetime  = 200             -- faster CursorHold, gitsigns etc.
opt.timeoutlen  = 300
opt.redrawtime  = 1500

-- ── Wrap & display ────────────────────────────────────────────────────────────
opt.wrap       = false
opt.list       = true             -- show invisible chars
opt.listchars  = { tab = "» ", trail = "·", nbsp = "␣" }
opt.conceallevel = 1              -- needed for markdown/obsidian

-- ── Folds (treesitter-based, nvim-ufo takes over at runtime) ──────────────────
o.foldmethod     = "expr"
o.foldexpr       = "v:lua.vim.treesitter.foldexpr()"
o.foldlevel      = 99
o.foldlevelstart = 99
o.foldenable     = true
o.foldcolumn     = "1"
o.fillchars      = "fold: ,foldopen:󰁂,foldclose:󰁅,foldsep: ,eob: "

-- ── Clipboard ─────────────────────────────────────────────────────────────────
-- OSC52 COPY  = yank in Neovim → lands in your LOCAL machine clipboard.
--              Works over SSH with no extra tools (WezTerm, iTerm2, Kitty,
--              Windows Terminal, tmux with set-clipboard on).
--
-- OSC52 PASTE READ hangs on SSH: the terminal is supposed to respond with
-- the clipboard contents but most SSH setups never send that response, so
-- Neovim waits the full timeout (~60s). Fix: fast unnamed-register fallback.
--
-- Workflow:
--   y (yank)   → OSC52 write → instantly in your local clipboard
--   p (paste)  → unnamed register → instant, no hang
--   Paste FROM local machine → terminal paste key (Ctrl+Shift+V / Cmd+V)
vim.g.clipboard = {
  name = "OSC52-copy-only",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    -- Skip OSC52 read (hangs on SSH). Return unnamed register content instead.
    ["+"] = function()
      local reg     = vim.fn.getreg('"')
      local regtype = vim.fn.getregtype('"')
      return { vim.split(reg, "\n"), regtype }
    end,
    ["*"] = function()
      local reg     = vim.fn.getreg('"')
      local regtype = vim.fn.getregtype('"')
      return { vim.split(reg, "\n"), regtype }
    end,
  },
}
opt.clipboard = "unnamedplus"

-- ── Mouse ─────────────────────────────────────────────────────────────────────
opt.mouse = "a"

-- ── Grep: use ripgrep if available ────────────────────────────────────────────
if vim.fn.executable("rg") == 1 then
  opt.grepprg    = "rg --vimgrep --smart-case"
  opt.grepformat = "%f:%l:%c:%m"
end

-- ── Ensure undodir exists ─────────────────────────────────────────────────────
local undodir = vim.fn.stdpath("data") .. "/undodir"
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, "p")
end
