local api = vim.api
local M = {}
local MAX_LINES = 200
-- Keep conversation in memory for interactive function
local messages = {} 
local chat_buf = nil  -- single buffer for conversation
-- Highlights Namespace
local ns_user = api.nvim_create_namespace("ChatGPTUser") or 0
local ns_assistant = api.nvim_create_namespace("ChatGPTAssistant") or 0

-- At the top of your module, after creating namespaces
vim.api.nvim_set_hl(0, "ChatGPTAssistant", {fg="#C678DD", bold=true})  -- purple color




-- Helper function to trim file paths from lines
local function trim_paths(lines)
    local new_lines = {}
    for _, line in ipairs(lines) do
        -- Remove everything before the first colon
        table.insert(new_lines, (line:gsub("^.-:", "")))
    end
    return new_lines
end


function M.SendBufferToChatGPT()
    local prompt = vim.fn.input("Question for ChatGPT: ")
    if prompt == "" then return end

    -- Get buffer lines and trim paths
    local lines = api.nvim_buf_get_lines(0, 0, -1, false)
    local trimmed_lines = trim_paths(lines)
    local text = table.concat(trimmed_lines, "\n")
    local query = text .. "\n\nQuestion: " .. prompt

    local python_bin = os.getenv("HOME") .. "/.venvs/openai/bin/python3"

    -- Create a temporary file for the query
    local tmpfile = os.tmpname()
    local f = io.open(tmpfile, "w")
    f:write(query)
    f:close()

    -- Python command reads the query from the file
    local cmd = string.format(
        '%s -c "import os, openai; openai.api_key=os.getenv(\'OPENAI_API_KEY\'); q=open(\'%s\').read(); r=openai.chat.completions.create(model=\'gpt-5-mini\', messages=[{\'role\':\'user\',\'content\':q}], temperature=1); print(r.choices[0].message.content)"',
        python_bin,
        tmpfile:gsub("([\"\\])", "\\%1")
    )

    local handle = io.popen(cmd)
    local result = handle:read("*a")
    handle:close()

    -- Delete the temp file
    os.remove(tmpfile)

    if result == "" then
        print("No response from ChatGPT. Check API key, internet connection, or Python venv.")
        return
    end

    -- Split into lines and truncate if too long
    local result_lines = vim.split(result, "\n")
    if #result_lines > MAX_LINES then
        for i = #result_lines, MAX_LINES + 1, -1 do
            table.remove(result_lines, i)
        end
        table.insert(result_lines, "-- output truncated --")
    end

    -- Open new buffer
    vim.cmd("enew")
    api.nvim_buf_set_lines(0, 0, -1, false, result_lines)
    vim.bo.buftype = ""
    vim.bo.swapfile = false
    vim.bo.bufhidden = "wipe"
    vim.wo.wrap = true
    vim.wo.linebreak = true
    vim.wo.scrolloff = 5
    api.nvim_win_set_cursor(0, {1,0})
end

-- =========================
-- Function 2: ChatGPTInteractive
-- =========================
local function append_message(buf, msg)
    local start_line = api.nvim_buf_line_count(buf)
    local lines = {}
    table.insert(lines, msg.role:upper() .. ":")
    for line in msg.content:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    table.insert(lines, "")
    api.nvim_buf_set_lines(buf, start_line, start_line, false, lines)

    local ns = (msg.role == "user") and ns_user or ns_assistant
    local hl_group = (msg.role == "user") and "Identifier" or "ChatGPTAssistant"
    for i = 1, #lines - 1 do
        api.nvim_buf_add_highlight(buf, ns, hl_group, start_line + i - 1, 0, -1)
    end
end

function M.ChatGPTInteractive()
    local buf = api.nvim_get_current_buf()

    -- Prompt user for input at the bottom
    local prompt = vim.fn.input("Question for ChatGPT: ")
    if prompt == "" then return end

    -- Append user message
    local user_msg = {role = "user", content = prompt}
    table.insert(messages, user_msg)
    append_message(buf, user_msg)

    -- Prepare Python request via temp file
    local tmpfile = os.tmpname()
    local f = io.open(tmpfile, "w")
    f:write(vim.fn.json_encode(messages))
    f:close()

    local python_bin = os.getenv("HOME") .. "/.venvs/openai/bin/python3"
    local cmd = string.format([[
    %s -c "import os, json, openai; openai.api_key=os.getenv('OPENAI_API_KEY'); \
    msgs=json.loads(open('%s').read()); \
    r=openai.chat.completions.create(model='gpt-5-mini', messages=msgs); \
    print(r.choices[0].message.content)"
        ]], python_bin, tmpfile)

    local handle = io.popen(cmd)
    local response = handle:read("*a")
    handle:close()
    os.remove(tmpfile)

    if response == "" then
        print("No response from ChatGPT.")
        return
    end

    -- Append assistant response
    local assistant_msg = {role="assistant", content=response}
    table.insert(messages, assistant_msg)
    append_message(buf, assistant_msg)

    -- Scroll to bottom
    local line_count = api.nvim_buf_line_count(buf)
    api.nvim_win_set_cursor(0, {line_count, 0})

    -- Save chat automatically on buffer close
    vim.api.nvim_create_autocmd("BufWipeout", {
        buffer = 0,
        once = true,
        callback = function()
            local chats_dir = os.getenv("HOME") .. "/nvim_chats"
            os.execute("mkdir -p " .. chats_dir)
            local timestamp = os.date("%Y%m%d_%H%M%S")
            local chat_file = string.format("%s/chat_%s.txt", chats_dir, timestamp)
            local f = io.open(chat_file, "w")
            if f then
                for _, msg in ipairs(messages) do
                    f:write(msg.role:upper() .. ":\n")
                    f:write(msg.content .. "\n\n")
                end
                f:close()
                print("Chat saved to: " .. chat_file)
            else
                print("Failed to save chat!")
            end
        end
    })
end

function M.SaveChat()
    if #messages == 0 then
        print("No chat messages to save.")
        return
    end

    -- Ask user for a chat name
    local chat_name = vim.fn.input("Enter chat name: ")
    if chat_name == "" then
        print("Chat not saved: no name provided.")
        return
    end

    -- Prepare directory
    local chats_dir = os.getenv("HOME") .. "/nvim_chats"
    os.execute("mkdir -p " .. chats_dir)

    -- Prepare filename with timestamp
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local chat_file = string.format("%s/%s_%s.txt", chats_dir, chat_name, timestamp)

    -- Write messages to file
    local f = io.open(chat_file, "w")
    if f then
        for _, msg in ipairs(messages) do
            f:write(msg.role:upper() .. ":\n")
            f:write(msg.content .. "\n\n")
        end
        f:close()
        print("Chat saved to: " .. chat_file)
    else
        print("Failed to save chat!")
    end
end

-- Map <leader>cs to save chat
vim.api.nvim_set_keymap(
    "n",
    "<leader>cs",
    "<cmd>lua require('chatgpt').SaveChat()<CR>",
    { noremap = true, silent = true }
)

return M

