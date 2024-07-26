local M = {}

local replace_termcodes = require"auto-session.utils.feedkeys".replace_termcodes
local neotree_toggle = require"auto-session.utils.neotree".neotree_toggle

function M.pre_save_hook(state_variable_name)
  -- Store as a global variable such that neotree will open on
  -- restore if it was open at end of last session.
  vim.api.nvim_set_var(
    state_variable_name,
    require('auto-session.utils.neotree').is_neotree_open()
  )
  -- Remember current tab and set mark in case
  -- closing tree or terminal switches tab.
  local tabpagenr = vim.fn.tabpagenr()
  local should_restore_mark = require "toggleterm.ui".find_open_windows() and
    vim.o.buftype ~= 'terminal'
  replace_termcodes('mT')
  -- Close the Neo-tree window for each tab.
  vim.cmd ':tabdo Neotree close'
  -- Close any open Toggleterm-terminals.
  if require "toggleterm.ui".find_open_windows() then
    require "toggleterm".toggle_all()
  end
  if should_restore_mark then replace_termcodes(tabpagenr.."gt`T") end
  -- Shada seem to not be auto-written after VimLeave.
  vim.cmd(":wshada")
end

function M.post_restore_hook(state_variable_name)
  neotree_toggle(state_variable_name)
end

return M

