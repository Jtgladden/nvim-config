-- local telescope = require("telescope")
-- local builtin = require("telescope.builtin")
--
-- -- Basic Telescope setup
-- telescope.setup({
--   defaults = {
--     layout_strategy = "horizontal",
--     layout_config = { preview_width = 0.6 },
--     sorting_strategy = "ascending",
--     mappings = {
--       i = {
--         ["<C-j>"] = require("telescope.actions").move_selection_next,
--         ["<C-k>"] = require("telescope.actions").move_selection_previous,
--       },
--     },
--   },
-- })

local telescope = require("telescope")
local builtin = require("telescope.builtin")
local previewers = require("telescope.previewers")
local utils = require("telescope.previewers.utils")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

-- Custom previewer that forces pdftotext
local pdf_previewer = previewers.new_buffer_previewer({
  define_preview = function(self, entry, status)
    local filepath = entry.path or entry.value
    if not filepath then return end

    -- Handle only PDFs
    if filepath:match("%.pdf$") then
      -- Copy OneDrive file to /tmp if needed (avoids COM Surrogate issue)
      local tmp_path = filepath
      if filepath:match("^/mnt/c/Users/.*/OneDrive") then
        tmp_path = "/tmp/" .. vim.fn.fnamemodify(filepath, ":t")
        vim.fn.system({ "cp", filepath, tmp_path })
      end

      -- Run pdftotext and load output into buffer
      local output = vim.fn.systemlist({ "pdftotext", "-layout", tmp_path, "-" })
      if vim.v.shell_error ~= 0 or #output == 0 then
        utils.set_preview_message(self.state.bufnr, status.winid, "Failed to render PDF via pdftotext.")
      else
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, output)
      end

    else
      -- Fallback: normal text preview
      utils.job_maker({ "cat", filepath }, self.state.bufnr, { value = filepath })
    end
  end,
})

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

  pickers = {
    find_files = {
      previewer = pdf_previewer,  -- 👈 Force our custom previewer here
    },
  },
})

-- Custom Actions
--

-- Custom action: open PDF as text
local function open_pdf_as_text(prompt_bufnr)
  local entry = action_state.get_selected_entry()
  actions.close(prompt_bufnr)
  local filepath = entry.path or entry.value

  if filepath:match("%.pdf$") then
    local output = vim.fn.systemlist({ "pdftotext", "-layout", filepath, "-" })
    vim.cmd("enew") -- open a new buffer
    vim.api.nvim_buf_set_lines(0, 0, -1, false, output)
    vim.bo.filetype = "text"
  else
    vim.cmd("edit " .. vim.fn.fnameescape(filepath))
  end
end

-- Attach the custom action to Telescope pickers
require("telescope").setup({
  defaults = {
    mappings = {
      i = {
        ["<CR>"] = open_pdf_as_text,
      },
      n = {
        ["<CR>"] = open_pdf_as_text,
      },
    },
  },
})



-- Try loading local Telescope overrides (ignored by git)
local local_telescope = vim.fn.stdpath("config") .. "/lua/plugins/local_telescope.lua"
if vim.fn.filereadable(local_telescope) == 1 then
  dofile(local_telescope)
end

-- Keymaps
-- Optional keymaps for generic Telescope commands
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Grep text" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find help" })


-- Home directory search
-- vim.keymap.set("n", "<leader>fa", function()
--   builtin.find_files({
--     cwd = vim.loop.os_homedir(),
--     prompt_title = "Home Directory Files"
--   })
-- end, { desc = "Find files from home" })

-- OneDrive search
vim.keymap.set("n", "<leader>fo", function()
  builtin.find_files({
    cwd = "/mnt/c/Users/jgladd55/OneDrive - Brigham Young University/",
    prompt_title = "OneDrive Files"
  })
end, { desc = "Find files in OneDrive" })
