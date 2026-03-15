-- ============================================================
--  options.lua
-- ============================================================
local opt = vim.opt
local o   = vim.o

-- ── UI ────────────────────────────────────────────────────────────────────────
opt.number         = true
opt.relativenumber = true
opt.cursorline     = true
opt.signcolumn     = "yes"
opt.colorcolumn    = "100"
opt.scrolloff      = 8
opt.sidescrolloff  = 8
opt.termguicolors  = true
opt.showmode       = false
opt.cmdheight      = 1
opt.pumheight      = 12
opt.splitright     = true
opt.splitbelow     = true
opt.laststatus     = 3
opt.winbar         = "%=%m %f"

-- ── Indentation ───────────────────────────────────────────────────────────────
opt.expandtab   = true
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
opt.encoding     = "utf-8"
opt.fileencoding = "utf-8"
opt.backup       = false
opt.swapfile     = false
opt.undofile     = true
opt.undodir      = vim.fn.stdpath("data") .. "/undodir"

-- ── Performance ───────────────────────────────────────────────────────────────
opt.updatetime = 200
opt.timeoutlen = 500   -- increased from 300 — gives more time before which-key
opt.redrawtime = 1500

-- ── Wrap & display ────────────────────────────────────────────────────────────
opt.wrap         = false
opt.list         = true
opt.listchars    = { tab = "» ", trail = "·", nbsp = "␣" }
opt.conceallevel = 1

-- ── Folds ─────────────────────────────────────────────────────────────────────
o.foldmethod     = "expr"
o.foldexpr       = "v:lua.vim.treesitter.foldexpr()"
o.foldlevel      = 99
o.foldlevelstart = 99
o.foldenable     = true
o.foldcolumn     = "1"
o.fillchars      = "fold: ,foldopen:-,foldclose:+,foldsep: ,eob: "

-- ── Clipboard ─────────────────────────────────────────────────────────────────
-- OSC52 COPY ONLY — this is the correct setup for a headless VPS over SSH.
--
-- How it works:
--   y / yy / Y   → yanks go into Neovim registers AND are sent via OSC52
--                  to your LOCAL machine clipboard instantly.
--   p / P        → pastes from Neovim's own yank register (register "0").
--                  Fast, no network, no hang.
--   Paste FROM local machine → use your terminal's paste shortcut
--                  (Ctrl+Shift+V, Cmd+V, or middle-click).
--                  This sends keystrokes directly to Neovim's insert mode.
--
-- What NOT to do:
--   Never use osc52.paste() on SSH — the terminal must respond to a query
--   escape sequence. Most SSH setups never respond → Neovim hangs 60 seconds.
--   The " keypress lag you saw was which-key reading register + via clipboard,
--   which also triggered this same hang (fixed by disabling which-key registers).

-- Set clipboard BEFORE defining vim.g.clipboard
opt.clipboard = "unnamedplus"

vim.g.clipboard = {
  name = "osc52-copy-only",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    -- Return yank register "0" — last explicit yank, always instant
    ["+"] = function() return { vim.split(vim.fn.getreg("0"), "\n"), vim.fn.getregtype("0") } end,
    ["*"] = function() return { vim.split(vim.fn.getreg("0"), "\n"), vim.fn.getregtype("0") } end,
  },
}

-- ── Mouse ─────────────────────────────────────────────────────────────────────
opt.mouse = "a"

-- ── Silence unused provider warnings ─────────────────────────────────────────
vim.g.loaded_perl_provider   = 0
vim.g.loaded_ruby_provider   = 0
vim.g.loaded_python3_provider = 0  -- we use mason for python tools, not this
vim.g.loaded_node_provider   = 0   -- we use mason for node tools, not this

-- ── Grep ──────────────────────────────────────────────────────────────────────
if vim.fn.executable("rg") == 1 then
  opt.grepprg    = "rg --vimgrep --smart-case"
  opt.grepformat = "%f:%l:%c:%m"
end

-- ── Ensure undodir exists ─────────────────────────────────────────────────────
local undodir = vim.fn.stdpath("data") .. "/undodir"
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, "p")
end
