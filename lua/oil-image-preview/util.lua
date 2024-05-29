local M = {}

---OS name
---@type string
local os_name = vim.uv.os_uname().sysname

---Check if macos
---@type boolean
M.is_mac = os_name == "Darwin"

---Check if linux
---@type boolean
M.is_linux = os_name == "Linux"

---Check if windows
---@type boolean
M.is_windows = os_name == "Windows_NT"

---Check if wsl
---@type boolean
M.is_wsl = vim.fn.has("wsl") == 1

---Check if unix
---@type boolean
M.is_unix = vim.fn.has("unix") == 1

---Path separator char
---@type string
local path_sep_char = string.sub(package.config, 1, 1)

---Path separator
---@type string
M.path_sep = M.is_windows and string.rep(path_sep_char, 2) or path_sep_char

---Debounce a function
---@param func function
---@param wait number
M.debounce = function(func, wait)
    local timer_id
    ---@vararg any
    return function(...)
        if timer_id ~= nil then
            vim.uv.timer_stop(timer_id)
        end
        local args = { ... }
        timer_id = assert(vim.uv.new_timer())
        vim.uv.timer_start(timer_id, wait, 0, function()
            func(unpack(args))
            timer_id = nil
        end)
    end
end

---Check if image file
---@param url string
M.isImage = function(url)
    local extension = url:match("^.+(%..+)$")
    local imageExt = { ".bmp", ".jpg", ".jpeg", ".png", ".gif" }

    return vim.iter(imageExt):any(function(ext)
        return extension == ext
    end)
end

---Get entry absolute path
---@return string ...
M.getEntryAbsolutePath = function()
    local oil = require("oil")
    local entry = oil.get_cursor_entry()
    local dir = oil.get_current_dir()
    if not entry or not dir then
        return
    end
    return dir .. entry.name, entry, dir
end

return M
