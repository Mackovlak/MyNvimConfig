# nvim-config

Production Neovim config for Ubuntu 24 VPS — works for any user, any machine.

## Quick install

```bash
# Full install (root — installs Neovim + all deps):
sudo bash install.sh

# Install for a specific user:
sudo bash install.sh --user john

# Already have Neovim, just clone config:
git clone https://github.com/YOUR_USERNAME/nvim-config ~/.config/nvim
```

First launch: open `nvim` and wait ~60 seconds for lazy.nvim to install all plugins.
Then run `:MasonUpdate` to install LSP servers.

## Plugin map

| File | What it configures |
|---|---|
| `plugins/colors.lua` | Tokyo Night colorscheme |
| `plugins/ui.lua` | Bufferline, lualine, noice, dashboard, which-key, trouble, zen-mode |
| `plugins/lsp.lua` | Mason, nvim-lspconfig, nvim-cmp, snippets, autopairs |
| `plugins/treesitter.lua` | Syntax, text objects (select function/class/arg) |
| `plugins/telescope.lua` | Fuzzy finder with fzf-native |
| `plugins/git.lua` | Gitsigns, Diffview, Neogit, Fugitive, Octo (GitHub PRs) |
| `plugins/editor.lua` | NvimTree, Harpoon, nvim-ufo, toggleterm, Spectre, Flash, surround, comment |
| `plugins/formatting.lua` | Conform (Prettier/Stylua/Black) + nvim-lint (eslint_d) |
| `plugins/extras.lua` | auto-session, neotest, todo-comments, oil.nvim, mini.nvim, markdown-preview |

## Clipboard over SSH

Uses OSC52 (built into Neovim 0.10+). Yank with `y` and the text lands in your
**local machine's** clipboard automatically — no xclip, no X11 forwarding.

Terminal requirements (one-time, on your local machine):
- **iTerm2**: Preferences → General → Selection → Allow clipboard access
- **WezTerm / Kitty**: works out of the box
- **tmux**: `set -s set-clipboard on` (the install script adds this)
- **Windows Terminal**: works out of the box

## Key bindings (leader = Space)

### Navigation
| Key | Action |
|---|---|
| `<leader>e` | Toggle file tree |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fr` | Recent files |
| `<leader>fb` | Buffers |
| `<leader>1-5` | Harpoon file 1-5 |
| `<leader>ha` | Add file to harpoon |
| `<leader>hm` | Harpoon menu |
| `s` | Flash jump |

### LSP
| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gr` | References |
| `K` | Hover docs |
| `<leader>rn` | Rename |
| `<leader>ca` | Code action |
| `<leader>f` | Format buffer |

### Git
| Key | Action |
|---|---|
| `<leader>gs` | Neogit (source control tab) |
| `<leader>dv` | Diffview (diff vs HEAD) |
| `<leader>dh` | File history |
| `]h` / `[h` | Next/prev hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hp` | Preview hunk |

### Sync config
| Key | Action |
|---|---|
| `<leader>pu` | `git pull` config + `:Lazy sync` |
