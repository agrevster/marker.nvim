--- A friendly NeoVim plugin that shows were marks are.
--- @module Marker
local M = {}

local signs = require("marker.signs")

--- @class Marker.config Configuration for marker.nvim
--- @field highlight_style vim.api.keyset.highlight The Vim highlight group used to highlight marks.
--- @field mark_regex string Used to specify which marks are shown with signs.
local DefaultConfig = {
  --- By default we want all marks that are alphabetical to show up...
  --- @see https://www.lua.org/pil/20.2.html
  mark_regex = "%a",
  highlight_style = {
    bg = "#8ecae6",
    fg = nil,
    bold = false,
    italic = true,
  },
}

--- @param config Marker.config | nil
M.setup = function(config)
  -- If the config isn't defined we can use the default one
  config = vim.tbl_deep_extend("force", DefaultConfig, config or {})
  vim.api.nvim_create_augroup("Marker", { clear = true })

  vim.api.nvim_set_hl(0, "MarkerMark", config.highlight_style)

  -- Create/update signs
  vim.api.nvim_create_autocmd(
    { "BufEnter", "BufWinEnter", "BufReadPost", "BufWritePost", "InsertLeave" },
    {
      group = "Marker",
      callback = function(args)
        signs.display_mark_signs(args.buf, config)
      end,
    }
  )

  -- Clean up signs on buffer wipe
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = "Marker",
    callback = function(args)
      signs.cleanup_mark_signs(args.buf)
    end,
  })

  vim.keymap.set("n", "dm", function()
    signs.delete_marks_command(config)
  end, { desc = "Deletes a mark" })
end

return M
