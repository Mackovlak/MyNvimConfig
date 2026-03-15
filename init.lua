-- ============================================================
--  init.lua
-- ============================================================
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- Silence provider warnings (we use mason, not legacy providers)
vim.g.loaded_perl_provider    = 0
vim.g.loaded_ruby_provider    = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider    = 0

-- auto-session: localoptions preserves filetype+highlighting on restore
vim.o.sessionoptions =
  "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("config.options")
require("config.keymaps")
require("config.autocmds")

require("lazy").setup("config.plugins", {
  change_detection = { notify = false },
  rocks = {
    enabled   = false,  -- silence luarocks/hererocks error
    hererocks = false,
  },
  ui = { border = "rounded" },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "matchit", "matchparen",
        "netrwPlugin", "tarPlugin",
        "tohtml", "tutor", "zipPlugin",
      },
    },
  },
})
