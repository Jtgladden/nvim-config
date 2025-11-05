local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

keymap('n', '<leader>e', ':NvimTreeToggle<CR>', opts)

-- Exit insert mode by typing 'jk' or kj
vim.keymap.set('i', 'jk', '<Esc>', { noremap = true, silent = true })
vim.keymap.set('i', 'kj', '<Esc>', { noremap = true, silent = true })
