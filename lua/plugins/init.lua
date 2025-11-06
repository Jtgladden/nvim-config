require("lazy").setup({
  {
    "dracula/vim",
    name = "dracula",
    priority = 1000, -- ensure it loads before others
    config = function()
      vim.g.dracula_transparent_bg = true
      vim.cmd.colorscheme("dracula")

       -- Clear highlight groups after colorscheme
      vim.cmd [[
        hi Normal guibg=NONE ctermbg=NONE
        hi NormalNC guibg=NONE ctermbg=NONE
        hi VertSplit guibg=NONE
        hi StatusLine guibg=NONE
        hi LineNr guibg=NONE
      ]]
    end,
  },
    -- Core plugins
  "nvim-tree/nvim-tree.lua",
  "nvim-tree/nvim-web-devicons",
    

  -- Telescope 
  {"nvim-telescope/telescope.nvim",
      tag = "0.1.8",
      dependencies = { "nvim-lua/plenary.nvim" },
    },

  {"nvim-telescope/telescope-media-files.nvim",
      dependencies = { "nvim-lua/popup.nvim", "nvim-lua/plenary.nvim" },
      config = function()
        require("telescope").load_extension("media_files")
      end,
    },


  -- LaTeX
  "lervag/vimtex",

  -- Autocomplete system
  "hrsh7th/nvim-cmp",             -- Completion engine
  "hrsh7th/cmp-buffer",           -- Source: buffer words
  "hrsh7th/cmp-path",             -- Source: file paths
  "hrsh7th/cmp-nvim-lsp",         -- Source: LSP
  "hrsh7th/cmp-omni",             -- Source: omnifunc (for VimTeX)
  "neovim/nvim-lspconfig",        -- LSP client
  -- Autopairs
  "windwp/nvim-autopairs",
  "L3MON4D3/LuaSnip",        -- snippet engine
  dependencies = {
    "saadparwaiz1/cmp_luasnip",  -- connects LuaSnip with nvim-cmp
  },
  "rafamadriz/friendly-snippets" -- community snippets 
})

require("plugins.vimtex")
require("plugins.nvim-tree")
require("plugins.cmp")
require("plugins.lsp")
require("plugins.autopairs")
require("plugins.luasnip")
require("plugins.telescope")


