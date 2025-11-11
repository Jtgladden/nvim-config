local api = vim.api
local M = {}
local MAX_LINES = 200 -- maximum lines to show from ChatGPT

function M.SendBufferToChatGPT(question)
    local ok, err = pcall(function()
        -- Use passed question or prompt interactively
        local prompt = question or vim.fn.input("Question for ChatGPT: ")
        if prompt == "" then return end

        -- Determine visual selection
        local start_line, end_line
        if vim.fn.mode() == "v" or vim.fn.mode() == "V" then
            start_line = vim.fn.line("'<") - 1
            end_line = vim.fn.line("'>")
        else
            start_line = 0
            end_line = -1
        end

        -- Get buffer text
        local lines = api.nvim_buf_get_lines(0, start_line, end_line, false)
        local text = table.concat(lines, "\n")
        local query = text .. "\n\nQuestion: " .. prompt

        -- Write query to temp file
        local tmpfile = os.tmpname()
        local f = io.open(tmpfile, "w")
        f:write(query)
        f:close()

        -- Python venv executable
        local python_bin = os.getenv("HOME") .. "/.venvs/openai/bin/python3"

        -- Python command
        local cmd = string.format(
            '%s -c "import os, openai; openai.api_key=os.getenv(\'OPENAI_API_KEY\'); q=open(\'%s\').read(); r=openai.chat.completions.create(model=\'gpt-5-mini\', messages=[{\'role\':\'user\',\'content\':q}], temperature=1); print(r.choices[0].message.content)"',
            python_bin,
            tmpfile:gsub("([\"\\])", "\\%1")
        )


        -- Run Python command
        local handle = io.popen(cmd)
        local result = handle:read("*a")
        handle:close()

        -- Delete temp file
        os.remove(tmpfile)

        if result == "" then
            error("No response from ChatGPT. Check API key, internet connection, or Python venv.")
        end

        -- Split into lines and truncate
        local result_lines = vim.split(result, "\n")
        if #result_lines > MAX_LINES then
            for i = #result_lines, MAX_LINES + 1, -1 do
                table.remove(result_lines, i)
            end
            table.insert(result_lines, "-- output truncated --")
        end

        -- Open new buffer and set lines
        vim.cmd("enew")
        api.nvim_buf_set_lines(0, 0, -1, false, result_lines)

        -- Buffer settings
        vim.bo.buftype = ""
        vim.bo.swapfile = false
        vim.bo.bufhidden = "wipe"
        vim.wo.wrap = true
        vim.wo.linebreak = true
        vim.wo.scrolloff = 5
        api.nvim_win_set_cursor(0, {1,0})
    end)

    if not ok then
        -- Open a buffer with the error
        vim.cmd("enew")
        local err_lines = vim.split(err, "\n")
        api.nvim_buf_set_lines(0, 0, -1, false, err_lines)
        vim.bo.buftype = ""
        vim.bo.swapfile = false
        vim.bo.bufhidden = "wipe"
        vim.wo.wrap = true
        vim.wo.linebreak = true
        print("ChatGPT call failed. See buffer for details.")
    end
end

return M



