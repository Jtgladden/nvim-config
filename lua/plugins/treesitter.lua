  require("nvim-treesitter.configs").setup({
    ensure_installed = { "c", "cpp", "lua", "python", "javascript", "typescript", "markdown" },
    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = { enable = true },
    textobjects = { enable = true },
  })
