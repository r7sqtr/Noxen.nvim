# Noxen.nvim
## Noxenとは？
Noxen.nvimは、Neovim中毒者・効率厨のために設計されたNeovimプラグインです。
タグやプロジェクトを使ってノートを作成・検索・整理できる使いやすいインターフェースを提供します。

## 📦 はじめに
### lazy.nvim

#### 推奨設定
```lua
{
  "r7sqtr/noxen.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "folke/snacks.nvim",  -- または "nvim-telescope/telescope.nvim"
    "nvim-tree/nvim-web-devicons", -- 任意
  },
  opts = {
    notes_dir = "~/.noxen",
    template = "default.md",
    ui = {
      position = "center",  -- "center"、"bottom"、"right"
      width = "80%", -- 数値または "%"
      height = "80%",  -- 数値または "%"
      border = "rounded",
      auto_save = true,
    },
    search = {
      engine = "snacks",  -- "snacks" または "telescope"
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
    { "<leader>mn", "<cmd>NoxenNew<cr>", desc = "Noxen: 新規ノート" },
    { "<leader>mf", "<cmd>NoxenFind<cr>", desc = "Noxen: ノート検索" },
    { "<leader>mg", "<cmd>NoxenGrep<cr>", desc = "Noxen: ノート全文検索" },
    { "<leader>mt", "<cmd>NoxenTags<cr>", desc = "Noxen: タグで検索" },
    { "<leader>mp", "<cmd>NoxenProjects<cr>", desc = "Noxen: プロジェクト切替" },
    { "<leader>mo", "<cmd>NoxenToggle<cr>", desc = "Noxen: ノート切替" },
    { "<leader>mq", "<cmd>NoxenQuick<cr>", desc = "Noxen: クイックノート" },
  },
}
```

## 🚀 使い方

### コマンド

| コマンド | 説明 |
|---------|------|
| `:NoxenNew [title]` | 新しいノートを作成する |
| `:NoxenFind [project]` | プロジェクトでノートを検索する |
| `:NoxenGrep [term]` | ノート全文を検索する |
| `:NoxenTags [tag]` | タグでノートを検索する |
| `:NoxenProjects [name]` | プロジェクトを切り替える |
| `:NoxenToggle` | UIを表示／非表示に切り替える |
| `:NoxenOpen [file]` | 指定したノートをUIで開く |
| `:NoxenClose` | UIを閉じる |
| `:NoxenQuick` | クイックノートを作成する |
| `:NoxenDelete [file]` | ノートを削除する |
| `:NoxenInfo` | プラグイン情報を表示する |


## ⚙️ デフォルト設定
```lua
require("noxen").setup({
  -- ノートを保存するディレクトリ
  notes_dir = "~/.noxen",

  -- 既定テンプレート
  template = "default.md",

  -- テンプレートディレクトリ
  templates_dir = "~/.noxen/templates",

  -- UI設定
  ui = {
    position = "center",      -- "center"、"bottom"、"right"
    width = 80,               -- 数値または "80%"
    height = 20,              -- 数値または "20%"
    border = "rounded",       -- "rounded"、"single"、"double"、"solid"、"none"
    title = " noxen.nvim ",
    auto_save = true,
    save_timeout = 1000,      -- ミリ秒
  },

  -- キーマップ
  keymaps = {
    toggle = "<leader>mn",
    new = "<leader>mn",
    find = "<leader>mf",
    tags = "<leader>mt",
    projects = "<leader>mp",
  },

  -- タグ設定
  tags = {
    format = "hashtag",       -- "hashtag" または "frontmatter"
    delimiter = ",",
  },

  -- フロントマター設定
  frontmatter = {
    enabled = true,
    default = {
      date = function() return os.date("%Y-%m-%d") end,
      tags = {},
    },
  },

  -- 検索設定
  search = {
    engine = "snacks",        -- "snacks" または "telescope"
    ignore_patterns = {
      "%.git/",
      "node_modules/",
      "%.DS_Store",
    },
  },
})
```


## 🛠️ 依存関係
- Neovim >= 0.8.0
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [nui.nvim](https://github.com/MunifTanjim/nui.nvim)
- [snacks.nvim](https://github.com/folke/snacks.nvim) または [Telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) （任意）

