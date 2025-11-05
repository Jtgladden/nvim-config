local luasnip = require("luasnip")
local types = require("luasnip.util.types")

-- Load snippets from friendly-snippets (optional)
require("luasnip.loaders.from_vscode").lazy_load()

-- Options
luasnip.config.set_config({
  history = true,           -- keep around last snippet
  updateevents = "TextChanged,TextChangedI",
  enable_autosnippets = true,
  store_selection_keys = "<Tab>",
  ext_opts = {
    [types.choiceNode] = {
      active = { virt_text = { { "●", "GruvboxOrange" } } }
    }
  }
})

-- Keymaps for expanding snippets
vim.keymap.set({"i", "s"}, "<Tab>", function()
  if luasnip.expand_or_jumpable() then
    return luasnip.expand_or_jump()
  else
    return "<Tab>"
  end
end, {expr = true, silent = true})

vim.keymap.set({"i", "s"}, "<S-Tab>", function()
  if luasnip.jumpable(-1) then
    return luasnip.jump(-1)
  else
    return "<S-Tab>"
  end
end, {expr = true, silent = true})

require("snippets.latex")

