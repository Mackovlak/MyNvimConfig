-- ============================================================
--  init.lua — entry point
--  Leader must be set BEFORE lazy loads anything
-- ============================================================
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- Bootstrap lazy.nvim (works on any machine, any user)
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
  -- Auto-discovers every file in lua/config/plugins/
  change_detection = { notify = false },
  ui = {
    border = "rounded",
    icons  = {
      cmd    = "⌘",  event  = "📅",
      ft     = "📂",  init   = "⚙",
      keys   = "🔑",  plugin = "🔌",
      runtime= "💻",  require= "🔗",
      source = "📄",  start  = "🚀",
      task   = "📌",  lazy   = "💤",
    },
  },
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
