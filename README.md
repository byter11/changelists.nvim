# ✨ changelists.nvim

An attempt to implement the [Changelists](https://www.jetbrains.com/help/idea/managing-changelists.html) feature from JetBrains in Neovim. 🖋️

## 📦 Installation

### Lazy.nvim
```lua
{
  "byter11/changelists.nvim",
  config = function(_, opts)
    require("changelists.signs").setup({
      ["test"] = {
        id = 1,
        name = "Test",
        sign = "CL_TEST",
        symbol = "▣",
      },
    })
  end
}
```

## 🌟 Features
- 🛠️ All changes are tracked under a default Changes list
- 🌈 Add custom lists:
  - 🔧 Config-based
  - ✨ Custom markers/signs
- 🚚 Move a hunk to a different changelist:
  - `:Changelists move_hunk <cl_name>`
- 📤 Stage a list:
  - `:Changelists stage_list <cl_name>`
- 🔍 View complete diff for a changelist:
  - `:Changelists show_list <cl_name>`
- 🤖 Autocompletion for commands
