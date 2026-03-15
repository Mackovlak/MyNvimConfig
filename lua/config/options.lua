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
opt.showmode       = false        -- lualine shows mode already
opt.cmdheight      = 1
opt.pumheight      = 12
opt.splitright     = true
opt.splitbelow     = true
opt.laststatus     = 3            -- single global statusline
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
opt.timeoutlen = 300
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
-- OSC52: yank → your LOCAL machine clipboard, zero tools needed over SSH.
--
-- The paste side uses xclip/xdotool as fallback. If neither is installed
-- the paste handler falls back to the unnamed register — no hang, no timeout.
-- The ONLY cause of the 60s hang is when the paste handler uses the OSC52
-- *read* escape sequence and the terminal never responds.
--
-- Rule: NEVER set vim.g.clipboard paste to osc52.paste() on a headless VPS.

opt.clipboard = "unnamedplus"

vim.g.clipboard = {
  name = "osc52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    -- Fast: read from PRIMARY/xclip if available, else unnamed reg (no hang)
    ["+"] = function()
      if vim.fn.executable("xclip") == 1 then
        local ok, result = pcall(vim.fn.systemlist, "xclip -o -selection clipboard 2>/dev/null")
        if ok and result and #result > 0 then return { result, "c" } end
      end
      if vim.fn.executable("xdotool") == 1 then
        local ok, result = pcall(vim.fn.systemlist, "xdotool getactivewindow getwindowgeometry 2>/dev/null")
        if ok and result then return { result, "c" } end
      end
      -- Fallback: return last yank from unnamed register (instant, no network)
      local lines = vim.split(vim.fn.getreg("0"), "\n")
      return { lines, vim.fn.getregtype("0") }
    end,
    ["*"] = function()
      if vim.fn.executable("xclip") == 1 then
        local ok, result = pcall(vim.fn.systemlist, "xclip -o -selection primary 2>/dev/null")
        if ok and result and #result > 0 then return { result, "c" } end
      end
      local lines = vim.split(vim.fn.getreg("0"), "\n")
      return { lines, vim.fn.getregtype("0") }
    end,
  },
}

-- ── Mouse ─────────────────────────────────────────────────────────────────────
opt.mouse = "a"

-- ── Providers — silence unused provider warnings ─────────────────────────────
-- We use mason for python/node tools; we don't need the legacy providers.
vim.g.loaded_perl_provider   = 0
vim.g.loaded_ruby_provider   = 0
-- python3 and node providers are enabled (used by some plugins)

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
