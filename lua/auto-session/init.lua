local M = {}

local is_plugin_blocked = require"auto-session.utils.plugininternal".is_plugin_blocked

local enable_autocommand = require"auto-session.session.autocommands".enable_autocommand

local create_usercommands = require("auto-session.session.usercommands").create_usercommands

local create_no_save_usercommands = require("auto-session.session.usercommands").create_no_save_usercommands

local pre_save_hook = require"auto-session.session.defaulthooks".pre_save_hook

local post_restore_hook = require"auto-session.session.defaulthooks".post_restore_hook

local default_blocked_filenames = { "GIT_COMMIT", "COMMIT_EDITMSG" }

local default_blocked_filetypes = { "netrw", "gitcommit" }

local default_session_opts =
  "blank,buffers,curdir,folds,help,tabpages,"..
  "winsize,winpos,terminal,localoptions"

local default_shada_opts = "!,'1"

local default_session_state_path = "/sessions/session.vim"

local default_enable_on_leave_autocmd = false

local default_enable_on_enter_autocmd = true

local neotree_state_variable_name = "NEOTREE_LAST_OPENED"

function M.setup(opts)
  local block_filetypes = (
    opts ~= nil and opts.block_filetypes
  ) or default_blocked_filetypes
  local block_filenames = (
    opts ~= nil and opts.block_filenames
  ) or default_blocked_filenames
  -- Pre-req for the mksession command.
  vim.o.sessionoptions = (
    opts ~= nil and opts.sessionoptions
  ) or default_session_opts
  -- Use shada default opts. ' is marks for previously edited
  -- files (1000). % saves and restores the bufferlist. !
  -- means options like GLOBAL_OPTION are persisted.
  vim.o.shada = (
    opts ~= nil and opts.shada
  ) or default_shada_opts
  local session_file_path = (
    opts ~= nil and opts.session_file_path
  ) or vim.fn.expand(vim.fn.stdpath("state") .. default_session_state_path)
  local enable_on_leave_autocmd = (
    opts ~= nil and
    opts.enable_on_leave_autocmd ~= nil and
    opts.enable_on_leave_autocmd
  ) or default_enable_on_leave_autocmd
  local enable_on_enter_autocmd = (
    opts ~= nil and
    opts.enable_on_enter_autocmd ~= nil and
    opts.enable_on_enter_autocmd
  ) or default_enable_on_enter_autocmd
  local function pre_save_hook_combined()
    pre_save_hook(neotree_state_variable_name)
    if opts.pre_save_hook then
      opts.pre_save_hook(neotree_state_variable_name)
    end
  end
  local function post_restore_hook_combined()
    post_restore_hook(neotree_state_variable_name)
    if opts.post_restore_hook then
      opts.post_restore_hook(neotree_state_variable_name)
    end
  end
  local is_plugin_blocked_value = is_plugin_blocked(block_filetypes, block_filenames)
  create_usercommands(
    session_file_path,
    pre_save_hook_combined,
    post_restore_hook_combined,
    is_plugin_blocked_value
  )
  if is_plugin_blocked_value then
    create_no_save_usercommands(
      session_file_path,
      pre_save_hook_combined,
      post_restore_hook_combined
    )
    return
  end
  if enable_on_leave_autocmd then
    enable_autocommand(
      "leave",
      session_file_path,
      pre_save_hook_combined,
      post_restore_hook_combined
    )
  end
  if enable_on_enter_autocmd then
    enable_autocommand(
      "enter",
      session_file_path,
      pre_save_hook_combined,
      post_restore_hook_combined
    )
  end
end

return M
