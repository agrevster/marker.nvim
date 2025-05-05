local Signs = {}

--- @param buffer_id number The Vim buffer ID that you wish to search for marks in
--- @param config Marker.config Marker's configuration
Signs.display_mark_signs = function(buffer_id, config)
  vim.fn.sign_unplace("MarkerMarks", { buffer = buffer_id })
  local marks = vim.fn.getmarklist(buffer_id)

  --- @param mark vim.fn.getmarklist.ret.item
  for i, mark in ipairs(marks) do
    --- @type string
    local mark_name = mark.mark

    if string.find(mark_name, config.mark_regex) ~= nil then
      --- Register a sign for each mark in the file
      vim.fn.sign_define("MarkerMark_" .. mark_name, {
        text = string.sub(mark_name, 2, 2),
        texthl = "MarkerMark",
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
end

--- Removed all placed signs and generated sign types.
--- @param buffer_id integer the id of the buffer to clean up marks from
Signs.cleanup_mark_signs = function(buffer_id)
  vim.fn.sign_unplace("MarkerMarks", { buffer = buffer_id })
  -- Remove all MarkerMark signs
  for _, sign in ipairs(vim.fn.sign_getdefined()) do
    if string.find(sign.name, "^MarkerMark_") ~= nil then
      vim.fn.sign_undefine(sign.name)
    end
  end
end

--- A command used to delete a mark from the current buffer
--- @param config Marker.config
Signs.delete_marks_command = function(config)
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
  Signs.display_mark_signs(buffer, config)
end

return Signs
