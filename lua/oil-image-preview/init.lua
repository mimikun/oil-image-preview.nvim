local util = require("oil-image-preview.util")
local windows = require("oil-image-preview.windows")
local macos = require("oil-image-preview.macos")
local linux = require("oil-image-preview.linux")
local wsl = require("oil-image-preview.wsl")

local M = {}

if util.is_wsl then
    M.openWithQuickLook = wsl.openWithQuickLook
    M.weztermPreview = wsl.weztermPreview
elseif util.is_windows then
    M.openWithQuickLook = windows.openWithQuickLook
    M.weztermPreview = windows.weztermPreview
elseif util.is_mac then
    M.openWithQuickLook = macos.openWithQuickLook
    M.weztermPreview = macos.weztermPreview
else
    M.openWithQuickLook = linux.openWithQuickLook
    M.weztermPreview = linux.weztermPreview
end

return M
