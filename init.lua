-- =========================
-- Bootstrap lazy.nvim
-- =========================
require("lazy_bootstrap")

-- =========================
-- Core Settings
-- =========================
require("core.options")
require("core.keymaps")

-- =========================
-- Plugins
-- =========================
require("plugins")

-- Load ChatGPT module
require("chatgpt")



-- vim.env.NVIM_LISTEN_ADDRESS = "/tmp/nvim"

