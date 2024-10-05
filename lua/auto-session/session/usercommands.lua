local M = {}

local save = require("auto-session.session.save").save
local restore = require("auto-session.session.restore").restore

local save_and_quit_command_name = "SaveSessionAndQuitNeovim"
local save_command_name = "SaveSession"
local restore_command_name = "RestoreSession"
local restore_conditional_command_name = "RestoreSessionConditional"

local function get_restore_session_fn(save_path, post_restore_hook)
  return function(options)
    vim.cmd"silent! tabdo tabclose"
    vim.cmd"silent! windo wincmd c"
    vim.cmd(options.bang and "silent! bufdo bd!" or "silent! bufdo bd")
    restore(options.args and
      options.args[1] or save_path
    )
    post_restore_hook()
  end
end

function M.create_usercommands(save_path, pre_save_hook, post_restore_hook, is_loading_blocked)
  vim.api.nvim_create_user_command(
    save_and_quit_command_name,
    function(options)
      pre_save_hook()
      save(options.args and
        options.args[1] or save_path
      )
      vim.cmd"wshada!"
      vim.cmd(options.bang and "qa!" or "qa")
    end, {
      nargs = "?",
      bang = true,
      desc = "Save session & quit nvim (wa*)"
    }
  )
  vim.api.nvim_create_user_command(
    save_command_name,
    function(options)
      pre_save_hook()
      save(options.args and
        options.args[1] or save_path
      )
      vim.cmd"wshada!"
    end,
    {
      nargs = "?",
      bang = true,
      desc = "Save session (wa*)"
    }
  )
  vim.api.nvim_create_user_command(
    restore_command_name,
    get_restore_session_fn(save_path, post_restore_hook),
    {
      nargs = "?",
      bang = true,
      desc = "Restore session (source session-file)"
    }
  )
  vim.api.nvim_create_user_command(
    restore_conditional_command_name,
    is_loading_blocked and function() end or get_restore_session_fn(save_path, post_restore_hook),
    {
      nargs = "?",
      bang = true,
      desc =
        "Restore session contingent on whether the autocommand "..
        "would have restored the session (source session-file)"
    }
  )

end

function M.create_no_save_usercommands(save_path, pre_save_hook, post_restore_hook)
  vim.api.nvim_create_user_command(
    save_and_quit_command_name,
    function(options)
      vim.cmd(options.bang and "qa!" or "qa")
    end, {
      nargs = "?",
      bang = true,
      desc = "Quit nvim - noop session (wa*)"
    }
  )
  vim.api.nvim_create_user_command(
    save_command_name,
    function(options) end,
    {
      nargs = "?",
      bang = true,
      desc = "Noop session (wa*)"
    }
  )
  vim.api.nvim_create_user_command(
    restore_command_name,
    function(options)
      M.clear_usercommands()
      M.create_usercommands(save_path, pre_save_hook, post_restore_hook)
      get_restore_session_fn(save_path, post_restore_hook)(options)
    end,
    {
      nargs = "?",
      bang = true,
      desc = "Restore session and enable saving (source session-file)"
    }
  )
end

function M.clear_usercommands()
  vim.api.nvim_del_user_command(save_and_quit_command_name)
  vim.api.nvim_del_user_command(save_command_name)
  vim.api.nvim_del_user_command(restore_command_name)
end

return M
