local telescope = require("telescope")
local builtin = require("telescope.builtin")

-- Basic Telescope setup
telescope.setup({
  defaults = {
    layout_strategy = "horizontal",
    layout_config = { preview_width = 0.6 },
    sorting_strategy = "ascending",
    mappings = {
      i = {
        ["<C-j>"] = require("telescope.actions").move_selection_next,
        ["<C-k>"] = require("telescope.actions").move_selection_previous,
      },
    },
  },
})

-- Keymaps
-- Optional keymaps for generic Telescope commands
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Grep text" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find help" })


-- Home directory search
vim.keymap.set("n", "<leader>fa", function()
  builtin.find_files({
    cwd = vim.loop.os_homedir(),
    prompt_title = "Home Directory Files"
  })
end, { desc = "Find files from home" })

-- OneDrive search
vim.keymap.set("n", "<leader>fo", function()
  builtin.find_files({
    cwd = "/mnt/c/Users/jgladd55/OneDrive - Brigham Young University/",
    prompt_title = "OneDrive Files"
  })
end, { desc = "Find files in OneDrive" })
