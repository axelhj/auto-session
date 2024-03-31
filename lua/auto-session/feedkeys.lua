M = {}

function M.replace_termcodes(cmd, remap)
  local opts = "x"
  if remap then
    opts = opts.."m"
  else
    opts = opts.."n"
  end
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(cmd, true, false, true),
    opts, -- n for noremap, m for remap existing/builtin
    false
  )
end

return M
