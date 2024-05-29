# oil-image-preview.nvim

**WORK IN PROGRESS**

## Requirements

- Neovim HEAD or nightly
    - other version not tested
- WezTerm
- If Windows: [QL-Win/QuickLook](https://github.com/QL-Win/QuickLook) portable version
- If Linux: [GNOME/sushi](https://gitlab.gnome.org/GNOME/sushi)
- If WSL:
    - Write `alias winwezterm="/path/to/windows/path/to/wezterm.exe"` in your shell config file.
    - EXISTS `/mnt/c/Program Files/PowerShell/7'/pwsh.exe`.
    - WSL INSTALLED in **SSD**.
        - In the case of HDD, it takes a long time.

## Features

- `openWithQuickLook`
- `weztermPreview`

### Windows

| Feature name        |   ⭕ ❌  |
| ------------------- | -------- |
| `openWithQuickLook`   |    ⭕    |
| `weztermPreview`      |    ⭕    |

It probably works.

### WSL

| Feature name        |   ⭕ ❌  |
| ------------------- | -------- |
| `openWithQuickLook`   |    ❌    |
| `weztermPreview`      |    ⭕    |

It probably works.

### Linux(not WSL)

| Feature name        |   ⭕ ❌  |
| ------------------- | -------- |
| `openWithQuickLook`   |    ⭕    |
| `weztermPreview`      |    ⭕    |

It probably works.

### macOS

| Feature name        |   ⭕ ❌  |
| ------------------- | -------- |
| `openWithQuickLook`   |    ⭕    |
| `weztermPreview`      |    ⭕    |

It probably works but I haven't tested it.

## Install and Setup

There is no default mapping.
You can map it to any key you like.

Here is an example(use lazy.nvim):

```lua
return {
    "stevearc/oil.nvim",
    dependencies = {
        "mimikun/oil-image-preview.nvim",
    },
    config = function()
        local oip = require("oil-image-preview")
        require("oil").setup({
            keymaps = {
                ["g<leader>"] = oip.openWithQuickLook,
                ["gp"] = oip.weztermPreview,
            },
        })
    end,
}
```

## Inspired

[Neovim + oil.nvim + Weztermで頑張って画像を表示する](https://zenn.dev/vim_jp/articles/5b5f704de07673)

