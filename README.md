# Noxen.nvim
## What Is Noxen?
Noxen.nvim is a Neovim plugin designed for Neovim addicts and efficiency enthusiasts.
It provides a user-friendly interface to create, search, and organize notes using tags and projects. With customizable templates and seamless integration with popular search tools like Snacks.nvim and Telescope.nvim, Noxen.nvim enhances your productivity by keeping your notes easily accessible within Neovim.


## 📦 Getting Started
### lazy.nvim

#### Using `opts` (recommended)
```lua
{
  "p2nthesilea/noxen.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "folke/snacks.nvim",  -- or "nvim-telescope/telescope.nvim"
    "nvim-tree/nvim-web-devicons", -- optional
  },
  opts = {
    notes_dir = "~/.noxen",
    template = "default.md",
    ui = {
      position = "center",  -- "center", "bottom", "right"
      width = "80%", -- number or "%"
      height = "80%",  -- number or "%"
      border = "rounded",
      auto_save = true,
    },
    search = {
      engine = "snacks",  -- "snacks" or "telescope"
    },
  },
  cmd = {
    "NoxenNew",
    "NoxenFind",
    "NoxenGrep",
    "NoxenTags",
    "NoxenProjects",
    "NoxenToggle",
    "NoxenQuick",
  },
  keys = {
    { "<leader>mn", "<cmd>NoxenNew<cr>", desc = "Noxen: New Note" },
    { "<leader>mf", "<cmd>NoxenFind<cr>", desc = "Noxen: Find Notes" },
    { "<leader>mg", "<cmd>NoxenGrep<cr>", desc = "Noxen: Grep Notes" },
    { "<leader>mt", "<cmd>NoxenTags<cr>", desc = "Noxen: Search by Tag" },
    { "<leader>mp", "<cmd>NoxenProjects<cr>", desc = "Noxen: Switch Project" },
    { "<leader>mo", "<cmd>NoxenToggle<cr>", desc = "Noxen: Toggle Note" },
    { "<leader>mq", "<cmd>NoxenQuick<cr>", desc = "Noxen: Quick Note" },
  },
}
```

## 🚀 Usage

### Commands

| Commands |  |
|---------|------|
| `:NoxenNew [title]` | Create a new note |
| `:NoxenFind [project]` | Search notes by project |
| `:NoxenGrep [term]` | Search notes by content |
| `:NoxenTags [tag]` | Search notes by tag |
| `:NoxenProjects [name]` | Switch project |
| `:NoxenToggle` | Toggle the UI |
| `:NoxenOpen [file]` | Open the specified note in the UI |
| `:NoxenClose` | Close the UI |
| `:NoxenQuick` | Create a quick note |
| `:NoxenDelete [file]` | Delete a note |
| `:NoxenInfo` | Show plugin information |


## ⚙️ Default Configuration
```lua
require("noxen").setup({
  -- Directory to save notes
  notes_dir = "~/.noxen",

  -- Default template
  template = "default.md",

  -- Template directory
  templates_dir = "~/.noxen/templates",

  -- UI settings
  ui = {
    position = "center",      -- "center", "bottom", "right"
    width = 80,               -- number or "80%"
    height = 20,              -- number or "20%"
    border = "rounded",       -- "rounded", "single", "double", "solid", "none"
    title = " noxen.nvim ",
    auto_save = true,
    save_timeout = 1000,      -- ms
  },

  -- Keymaps
  keymaps = {
    toggle = "<leader>mn",
    new = "<leader>mn",
    find = "<leader>mf",
    tags = "<leader>mt",
    projects = "<leader>mp",
  },

  -- Tag settings
  tags = {
    format = "hashtag",       -- "hashtag" or "frontmatter"
    delimiter = ",",
  },

  -- Frontmatter settings
  frontmatter = {
    enabled = true,
    default = {
      date = function() return os.date("%Y-%m-%d") end,
      tags = {},
    },
  },

  -- Search settings
  search = {
    engine = "snacks",        -- "snacks" or "telescope"
    ignore_patterns = {
      "%.git/",
      "node_modules/",
      "%.DS_Store",
    },
  },
})
```


## 🛠️ Dependencies
- Neovim >= 0.8.0
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [nui.nvim](https://github.com/MunifTanjim/nui.nvim)
- [snacks.nvim](https://github.com/folke/snacks.nvim) or [Telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) (optional)

