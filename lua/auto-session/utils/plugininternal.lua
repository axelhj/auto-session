local M = {}

function M.is_plugin_blocked(block_filetypes, block_filenames)
  if vim.fn.argc() ~= 0 then return true end
  for _, filetype in ipairs(block_filetypes) do
    if filetype == vim.o.filetype then
      return true
    end
  end
  for _, filename in ipairs(block_filenames) do
    local buf_filename = vim.fn.fnamemodify(vim.fn.bufname(), ":t")
    if filename == buf_filename then
      return true
    end
  end
  return false
end

return M
