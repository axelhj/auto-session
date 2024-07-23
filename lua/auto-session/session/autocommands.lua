local M = {
  path = nil,
  pre_save_hook = nil,
  post_restore_hook = nil
}

local save = require"auto-session.session.save".save

local restore = require"auto-session.session.restore".restore

local enter_augroup_name = "auto_session_enter_autocommands_group"

local leave_augroup_name = "auto_session_leave_autocommands_group"

vim.api.nvim_create_augroup(enter_augroup_name, { clear = true })

vim.api.nvim_create_augroup(leave_augroup_name, { clear = true })

local function on_leave_autocommand_body()
  if M.pre_save_hook then
    M.pre_save_hook()
  end
  save(M.path)
end

local function on_enter_autocommand_body()
  restore(M.path)
  if M.post_restore_hook then
    M.post_restore_hook()
  end
end

function M.enable_autocommand(which, path, pre_save_hook, post_restore_hook)
  M.path = path
  M.pre_save_hook = pre_save_hook
  M.post_restore_hook = post_restore_hook
  if which == "all" or which == "leave" then
    vim.api.nvim_create_autocmd(
      "VimLeave",
      { callback = on_leave_autocommand_body }
    )
  end
  if which == "all" or which == "enter" then
    vim.api.nvim_create_autocmd(
      "UIEnter",
      { callback = on_enter_autocommand_body }
    )
  end
end

function M.disable_autocommands()
  vim.api.nvim_clear_autocmds({ group = enter_augroup_name })
  vim.api.nvim_clear_autocmds({ group = leave_augroup_name })
end

return M
