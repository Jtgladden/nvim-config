-- vim.g.vimtex_view_method = 'zathura'
vim.g.vimtex_compiler_method = 'latexmk'
vim.g.vimtex_compiler_latexmk = {
  build_dir = 'build',
  continuous = 1,
  callback = 1
}

-- Try loading local overrides (ignored by git)
local local_vimtex = vim.fn.stdpath("config") .. "/lua/plugins/local_vimtex.lua"
if vim.fn.filereadable(local_vimtex) == 1 then
  dofile(local_vimtex)
end

-- -- Custom keybinding: <Space>b to build + open PDF in Skim
vim.keymap.set('n', '<leader>b', ':VimtexView<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>c', ':VimtexClean<CR>', { noremap = true, silent = true, desc = "Clean LaTeX build files" })
-- -- Unnecessary ?
-- vim.keymap.set('n', '<leader>b', function()
--   vim.cmd('VimtexCompile')
--   vim.cmd('VimtexView')
-- end, { noremap = true, silent = true, desc = "Build and view LaTeX in Skim" })
--

vim.g.vimtex_complete_enabled = 1
vim.g.vimtex_complete_close_braces = 1
vim.g.vimtex_complete_bib = { simple = 1 }

