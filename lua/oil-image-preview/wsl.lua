local M = {}

local util = require("oil-image-preview.util")

local debounce = util.debounce

-- NOTE: ONLY wsl
M.openWithQuickLook = {
    callback = function()
        vim.notify("WSL is not support!!!", vim.log.levels.ERROR)
    end,
    desc = "Open with QuickLook",
}

-- NOTE: unused?
--local OIL_PREVIEW_ENTRY_ID_VAR_NAME = "OIL_PREVIEW_ENTRY_ID"

-- NOTE: ONLY wsl
---Get the pain id in which neovim is open
---@return number|nil
local function getNeovimWeztermPane()
    ---'/mnt/c/Program Files/PowerShell/7/pwsh.exe' -c 'Write-Output $env:WEZTERM_PANE'
    ---@type table
    local cmd = {
        "winpwsh",
        "-c",
        "Write-Output $env:WEZTERM_PANE",
    }

    local obj = vim.system(cmd, { text = true }):wait()
    local wezterm_pane_id = obj.stdout

    if not wezterm_pane_id then
        vim.notify("Wezterm pane not found", vim.log.levels.ERROR)
        return
    end
    return tonumber(wezterm_pane_id)
end

-- NOTE: ONLY wsl
---Activate a wezterm pane using wezterm_pane_id
---@param wezterm_pane_id number
local activeWeztermPane = function(wezterm_pane_id)
    ---@type table
    local cmd = {
        "winwezterm",
        "cli",
        "activate-pane",
        "--pane-id",
        wezterm_pane_id,
    }
    vim.system(cmd)
end

-- NOTE: ONLY wsl
---Open a new wezterm pane, and get its pane id
---@param opt table
local openNewWeztermPane = function(opt)
    local _opt = opt or {}
    local percent = _opt.percent or 30
    local direction = _opt.direction or "right"

    ---@type table
    local cmd = {
        "winwezterm",
        "cli",
        "split-pane",
        ("--percent=%d"):format(percent),
        ("--%s"):format(direction),
        "--",
        "pwsh",
    }
    local obj = vim.system(cmd, { text = true }):wait()
    local wezterm_pane_id = assert(tonumber(obj.stdout))

    return wezterm_pane_id
end

-- NOTE: ONLY wsl
---Close the wezterm pane for wezterm_pane_id
---@param wezterm_pane_id number
local closeWeztermPane = function(wezterm_pane_id)
    ---@type table
    local cmd = {
        "winwezterm",
        "cli",
        "kill-pane",
        ("--pane-id=%d"):format(wezterm_pane_id),
    }
    vim.system(cmd)
end

-- XXX: test
M.weztermPreview = {
    callback = function()
        local before = getNeovimWeztermPane()
        local opened = openNewWeztermPane()
        activeWeztermPane(before)
        closeWeztermPane(opened)
        vim.notify("Opened Pane id: " .. opened, vim.log.levels.ERROR)
    end,
    desc = "test",
}

-- TODO: need test
-- NOTE: ONLY wsl
---Send command to the wezterm pane
---@param wezterm_pane_id number
-- TODO: fix type
---@param command any
local sendCommandToWeztermPane = function(wezterm_pane_id, command)
    local cmd = {
        "echo",
        ("'%s'"):format(command),
        "|",
        "winwezterm",
        "cli",
        "send-text",
        "--no-paste",
        ("--pane-id=%d"):format(wezterm_pane_id),
    }
    vim.fn.system(table.concat(cmd, " "))
end

-- TODO: need test
-- NOTE: ONLY wsl
---Get a list of wezterm panes
-- TODO: fix type
---@return any
local function listWeztermPanes()
    local cli_result = vim.system({
        "winwezterm",
        "cli",
        "list",
        ("--format=%s"):format("json"),
    }, { text = true }):wait()
    local json = vim.json.decode(cli_result.stdout)
    local panes = vim.iter(json):map(_l("obj: { pane_id = obj.pane_id, tab_id = obj.tab_id }"))

    return panes
end

-- TODO: need test
-- NOTE: ONLY windows, wsl
---Get the wezterm pane id where the image preview is displayed
---@return number|nil
local function getPreviewWeztermPaneId()
    local panes = listWeztermPanes()
    local neovim_wezterm_pane_id = getNeovimWeztermPane()
    local current_tab_id = assert(panes:find(function(obj)
        return obj.pane_id == neovim_wezterm_pane_id
    end)).tab_id
    local preview_pane = panes:find(function(obj)
        return --
            obj.tab_id == current_tab_id --
                and tonumber(obj.pane_id) > tonumber(neovim_wezterm_pane_id) -- new pane id should be greater than current pane id
    end)
    return preview_pane ~= nil and preview_pane.pane_id or nil
end

-- TODO: need test
-- NOTE: ONLY windows, wsl
---Open the image preview pane and, get the wezterm pane id
---@return number|nil
local function openWeztermPreviewPane()
    local preview_pane_id = getPreviewWeztermPaneId()
    if preview_pane_id == nil then
        preview_pane_id = openNewWeztermPane({ percent = 30, direction = "right" })
    end
    return preview_pane_id
end

-- TODO: need test
-- NOTE: ONLY windows, wsl
---Check if opened wezterm image preview pane
---@return boolean
local is_wezterm_preview_open = function()
    return getPreviewWeztermPaneId() ~= nil
end

--[[ TODO:
-- NOTE: ONLY windows, wsl
M.weztermPreview = {
    callback = function()
        if is_wezterm_preview_open() then
            closeWeztermPane(getPreviewWeztermPaneId())
        end

        local oil = require("oil")
        local oil_util = require("oil.util")
        local perviw_entry_id = nil
        local prev_cmd = nil

        local neovim_wezterm_pane_id = getNeovimWeztermPane()
        local bufnr = vim.api.nvim_get_current_buf()

        local updateWeztermPreview = debounce(
            vim.schedule_wrap(function()
                if vim.api.nvim_get_current_buf() ~= bufnr then
                    return
                end
                local entry = oil.get_cursor_entry()
                -- Don't update in visual mode. Visual mode implies editing not browsing,
                -- and updating the preview can cause flicker and stutter.
                if entry ~= nil and not oil_util.is_visual_mode() then
                    local preview_pane_id = openWeztermPreviewPane()
                    activeWeztermPane(neovim_wezterm_pane_id)

                    if perviw_entry_id == entry.id then
                        return
                    end

                    if prev_cmd == "bat" then
                        sendCommandToWeztermPane(preview_pane_id, "q")
                        prev_cmd = nil
                    end

                    local path = assert(util.getEntryAbsolutePath())
                    local command = ""
                    if entry.type == "directory" then
                        local cmd = "ls -l"
                        command = command .. ("%s %s"):format(cmd, path)
                        prev_cmd = cmd
                    elseif entry.type == "file" and util.isImage(path) then
                        local cmd = "wezterm imgcat"
                        command = command .. ("%s %s"):format(cmd, path)
                        prev_cmd = cmd
                    elseif entry.type == "file" then
                        local cmd = "bat"
                        command = command .. ("%s %s"):format(cmd, path)
                        prev_cmd = cmd
                    end

                    sendCommandToWeztermPane(preview_pane_id, command)
                    -- NOTE: unused?
                    --local previw_entry_id = entry.id
                end
            end),
            50
        )

        updateWeztermPreview()

        local config = require("oil.config")
        if config.preview.update_on_cursor_moved then
            vim.api.nvim_create_autocmd("CursorMoved", {
                desc = "Update oil wezterm preview",
                group = "Oil",
                buffer = bufnr,
                callback = function()
                    updateWeztermPreview()
                end,
            })
        end

        vim.api.nvim_create_autocmd({ "BufLeave", "BufDelete", "VimLeave" }, {
            desc = "Close oil wezterm preview",
            group = "Oil",
            buffer = bufnr,
            callback = function()
                closeWeztermPane(getPreviewWeztermPaneId())
            end,
        })
    end,
    desc = "Preview with Wezterm",
}
]]

return M
