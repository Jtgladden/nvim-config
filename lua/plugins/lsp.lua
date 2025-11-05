-- Modern Neovim 0.11+ LSP configuration for texlab

-- Create the configuration
vim.lsp.config["texlab"] = {
  cmd = { "texlab" },
  filetypes = { "tex", "bib", "plaintex", "latex" },
  root_markers = { ".git", ".latexmkrc" },
  settings = {
    texlab = {
      auxDirectory = "build",
      bibtexFormatter = "texlab",
      build = {
        executable = "latexmk",
        args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
        onSave = true,
      },
      chktex = { onEdit = false, onOpenAndSave = true },
      diagnosticsDelay = 300,
      forwardSearch = {
        executable = "open",
        args = { "-a", "Skim", "%p" },
      },
    },
  },
}

-- Start the server automatically when opening TeX files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex", "bib" },
  callback = function()
    vim.lsp.start(vim.lsp.config["texlab"])
  end,
})

vim.diagnostic.config({
  virtual_text = false,
  signs = false,
  underline = false,
})


