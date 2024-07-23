M = {}

function M.save(file_path)
  vim.cmd("mksession! " .. file_path)
end

return M
