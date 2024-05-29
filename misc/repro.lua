-- base: https://github.com/folke/lazy.nvim/blob/main/.github/ISSUE_TEMPLATE/bug_report.yml

local root = vim.fn.fnamemodify("./.repro", ":p")

for _, name in ipairs({ "config", "data", "state", "cache" }) do
    vim.env[("XDG_%s_HOME"):format(name:upper())] = root .. "/" .. name
end

local lazypath = root .. "/plugins/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.runtimepath:prepend(lazypath)

local plugins = {
    "folke/tokyonight.nvim",
    "stevearc/oil.nvim",
    --"mimikun/oil-image-preview.nvim",
    { dir = vim.fn.expand("$GHQ_ROOT/github.com/mimikun/dev-plugins/oil-image-preview.nvim") },
    -- add any other plugins here
}

require("lazy").setup(plugins, {
    root = root .. "/plugins",
    concurrency = 1,
    git = {
        timeout = 300,
    },
})

vim.cmd.colorscheme("tokyonight")
vim.opt.ambiwidth = "double"
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local oip = require("oil-image-preview")
require("oil").setup({
    keymaps = {
        ["g<leader>"] = oip.openWithQuickLook,
        ["gp"] = oip.weztermPreview,
    },
})

vim.keymap.set("n", "<leader>q", ":qa!<CR>")
vim.keymap.set("n", "<leader>f", "<cmd>Oil<CR>")
-- add anything else here
