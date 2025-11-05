-- =========================
-- Bootstrap lazy.nvim
-- =========================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- =========================
-- Plugins
-- =========================
require("lazy").setup({
  "lervag/vimtex",          -- LaTeX tools
  "dracula/vim",            -- Colorscheme
  "nvim-tree/nvim-tree.lua",-- File explorer
  "nvim-tree/nvim-web-devicons", -- Icons for nvim-tree
})

-- =========================
-- General settings
-- =========================
vim.o.number = true
vim.o.relativenumber = true
vim.o.termguicolors = true
vim.g.mapleader = " "        -- Space as leader key
vim.cmd("colorscheme dracula")

-- =========================
-- VimTeX configuration
-- =========================
vim.g.vimtex_view_method = 'skim'        -- PDF viewer on macOS
vim.g.vimtex_compiler_method = 'latexmk'
vim.g.vimtex_compiler_latexmk = {
  build_dir = 'build',
  continuous = 1,
}

-- Custom keybinding: <Space>b to build + open PDF in Skim
vim.keymap.set('n', '<leader>b', function()
  vim.cmd('VimtexCompile')
  vim.cmd('VimtexView')
end, { noremap = true, silent = true, desc = "Build and view LaTeX in Skim" })

-- =========================
-- nvim-tree configuration
-- =========================
require("nvim-tree").setup({
  view = {
    width = 30,
    side = "left",
  },
  renderer = {
    highlight_git = true,
    icons = {
      show = { git = true, folder = true, file = true, folder_arrow = true },
    },
  },
  filters = { dotfiles = false },
})

-- Toggle file tree with <Space>e
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })


