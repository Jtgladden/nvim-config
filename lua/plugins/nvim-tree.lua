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

