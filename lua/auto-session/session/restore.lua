M = {}

function M.restore(file_path)
  local cmd = "silent source " .. file_path
  local success, result = pcall(function(arg) vim.cmd(arg) end, cmd)
  if not success then
    print("Restoring session "..file_path.." failed. "..vim.inspect(result))
  end
end

return M
