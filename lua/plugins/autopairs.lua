require("nvim-autopairs").setup({
  check_ts = true,        -- use treesitter to check for pairs
  enable_check_bracket_line = true, -- don't add pairs if already on the line
  map_cr = true,           -- map <CR> to confirm brackets
  disable_filetype = { "TelescopePrompt", "vim" },
})

