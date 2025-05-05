local M = {}

--- Creates signs for every mark in the file and places them.
--- @param buffer_id number The Vim buffer ID that you wish to search for marks in
local display_mark_signs = function(buffer_id)
  vim.fn.sign_unplace("MarkerMarks", { buffer = buffer_id })
  local marks = vim.fn.getmarklist(buffer_id)

  --- @param mark vim.fn.getmarklist.ret.item
  for i, mark in ipairs(marks) do
    --- @type string
    local mark_name = mark.mark

    if string.find(mark_name, "%a") == nil then
      return
    end

    --- Register a sign for each mark in the file
    vim.fn.sign_define("MarkerMark_" .. mark_name, {
      text = string.sub(mark_name, 2, 2),
      texthl = "IncSearch",
    })

    vim.fn.sign_place(
      i,
      "MarkerMarks",
      "MarkerMark_" .. mark_name,
      buffer_id,
      { lnum = mark.pos[2] }
    )
  end
end

--- Removed all placed signs and generated sign types.
--- @param buffer_id integer the id of the buffer to clean up marks from
local cleanup_mark_signs = function(buffer_id)
  vim.fn.sign_unplace("MarkerMarks", { buffer = buffer_id })
  -- Remove all MarkerMark signs
  for _, sign in ipairs(vim.fn.sign_getdefined()) do
    if string.find(sign.name, "^MarkerMark_") ~= nil then
      vim.fn.sign_undefine(sign.name)
    end
  end
end

local delete_marks_command = function()
  vim.notify("Enter a mark to delete: ", 1)
  local ok, char = pcall(vim.fn.getcharstr)
  if not ok or char == "\027" then
    vim.notify("") -- Clear the line to remove the prompt
    return
  end

  -- Validate input
  if #char ~= 1 then
    vim.notify("Invalid mark name", vim.log.levels.ERROR)
    return
  end

  local buffer = vim.api.nvim_get_current_buf()

  vim.api.nvim_buf_del_mark(buffer, char)
  vim.notify("Deleted mark '" .. char)
  display_mark_signs(buffer)
end

M.setup = function()
  vim.api.nvim_create_augroup("Marker", { clear = true })

  -- Create/update signs
  vim.api.nvim_create_autocmd(
    { "BufEnter", "BufWinEnter", "BufReadPost", "BufWritePost", "InsertLeave" },
    {
      group = "Marker",
      callback = function(args)
        display_mark_signs(args.buf)
      end,
    }
  )

  -- Clean up signs on buffer wipe
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = "Marker",
    callback = function(args)
      cleanup_mark_signs(args.buf)
    end,
  })

  require("which-key").add({
    {
      "<leader>xc",
      function()
        display_mark_signs(vim.api.nvim_get_current_buf())
      end,
      desc = "Test Create",
      icon = "󰙨",
    },
  })

  require("which-key").add({
    {
      "<leader>xr",
      function()
        cleanup_mark_signs(vim.api.nvim_get_current_buf())
      end,
      desc = "Test Remove",
      icon = "󰙨",
    },
  })

  vim.keymap.set("n", "dm", delete_marks_command, { desc = "Delete a mark" })
end

return M
