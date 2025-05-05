# Marker.nvim
> A friendly NeoVim plugin that shows where marks are

#### Demo
![](./demo.gif) 

### Features
*I'm new to making NeoVim Plugins, feel free to make an issue if you have suggestions or find an issue.* 


1. Creates Vim signs that show where marks are placed in a file.
2. Adds a binding to allow users to easily delete marks


## Installing with lazy

```lua
{
  'agrevster/marker.nvim',
  config = function()
    require('marker').setup {
      mark_regex = '%a', -- Used to specify which marks are shown with signs.
      highlight_style = { -- The Vim highlight group used to highlight marks.
        bg = '#8ecae6',
        fg = nil,
        bold = false,
        italic = true,
      },
      keys = { -- Keybindings
        delete_mark = 'dm', -- Keybind to delete mark
      },
    }
  end,
}
```
