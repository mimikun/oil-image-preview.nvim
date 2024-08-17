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

--Check if audio file
M.isAudio = function(url)
    local extension = url:match("^.+(%..+)$")
    local audioExt = { ".mp3", ".wav", ".ogg", ".flac", ".m4a" }
    return vim.iter(audioExt):any(function(ext)
        return extension == ext
    end)
end

-- Function that checks if a file is compatible with bat using the 'file' command
M.isBatCompatible = function(path)
    local handle = io.popen(("file --mime-type -b %s"):format(vim.fn.shellescape(path)))
    local mime_type = handle:read("*a"):gsub("%s+", "")
    handle:close()

    -- Check if MIME type starts with "text/"
    if mime_type:match("^text/") then
        return true
    end

    -- Other MIME types that are supported by bat
    local additional_types = {
        ["application/json"] = true,
        ["application/xml"] = true,
        ["application/javascript"] = true,
        -- Add other specific MIME types here
    }

    return additional_types[mime_type] or false
end

---Check if image file
---@param url string
M.isImage = function(url)
    local handle = io.popen(("file --mime-type -b %s"):format(vim.fn.shellescape(url)))
    local mime_type = handle:read("*a"):gsub("%s+", "")
    handle:close()
    if mime_type:match("^image/") then
        return true
    end
    return false
end

---Function that checks if a file is compatible with mpv using the 'file' command
---@param url string
---@return boolean
M.isMPVCompatible = function(url)
    local handle = io.popen(("file --mime-type -b %s"):format(vim.fn.shellescape(url)))
    local mime_type = handle:read("*a"):gsub("%s+", "")
    handle:close()
    -- Check if MIME type starts with "video/"
    if mime_type:match("^video/") then
        return true
    end
    -- Other MIME types that are supported by mpv
    local additional_types = {
        ["application/mp4"] = true,
        ["application/ogg"] = true,
        ["application/x-matroska"] = true,
        ["inode/x-empty"] = true,
        -- Add other specific MIME types here
    }
    return additional_types[mime_type] or false
end

--- Function that checks if a file is compatibly with convert (ImageMagick) for using `convert 'file' 'pw.png'`
--- @param url string
--- @return boolean
M.isImageMagickCompatible = function(url)
    local handle = io.popen(("file --mime-type -b %s"):format(vim.fn.shellescape(url)))
    local mime_type = handle:read("*a"):gsub("%s+", "")
    handle:close()
    -- Other MIME types that are supported by convert
    local additional_types = {
        ["application/pdf"] = true,
        ["image/vnd.djvu"] = true,
        ["application/postscript"] = true,
        ["application/eps"] = true,
        -- Add other specific MIME types here
    }
    return additional_types[mime_type] or false
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
    return dir .. entry.name, string.format("%q", dir .. entry.name), entry, dir
end

return M
