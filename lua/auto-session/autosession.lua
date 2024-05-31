local M = {}

local replace_termcodes = require"auto-session.feedkeys".replace_termcodes

local neotree_state = "NEOTREE_LAST_OPENED"

local function neotree_toggle()
  if vim.g[neotree_state] then
    require("neo-tree.command")
      .execute {
        action = 'show',
        reveal_force_cwd = true,
      }
    local timer = vim.loop.new_timer()
    -- Timer is necessary because neo-tree must execute
    -- autocommands or async code before the command has
    -- full effect.
    timer:start(100, 0, vim.schedule_wrap(function()
      replace_termcodes("<C-w>=<C-w>w", false)
      timer:start(100, 0, vim.schedule_wrap(function()
        replace_termcodes("<C-w>w<C-w>w", false)
      end))
    end))
  end
end

local function save(file_path)
  vim.cmd("mksession! " .. file_path)
end

local function restore(file_path)
  local cmd = "silent source " .. file_path
  local success, result = pcall(function(arg) vim.cmd(arg) end, cmd)
  if not success then
    print("Restoring session "..file_path.." failed. "..vim.inspect(result))
  end
end

local function pre_save()
  -- Store as a global variable such that neotree will open on
  -- restore if it was open at end of last session.
  vim.api.nvim_set_var(
    neotree_state,
    require('auto-session.neotreeopened').is_neotree_open()
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
  -- Doesn't autosave after VimLeave. :wshada without
  -- forced write frequently fails.
  vim.cmd(":wshada!")
end

local function post_restore()
  neotree_toggle()
end

local function is_plugin_blocked(block_filetypes, block_filenames)
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

function M.setup(opts)
  -- Help auto-session do its thing
  vim.o.sessionoptions = (
    opts ~= nil and opts.sessionoptions
  ) or "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

  -- Use shada default opts. ' is marks for previously edited
  -- files (1000). % saves and restores the bufferlist. !
  -- means options like GLOBAL_OPTION are persisted.
  vim.o.shada = (
    opts ~= nil and opts.shada
  ) or '!,\'1'

  local session_file_path = (
    opts ~= nil and opts.session_file_path
  ) or vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/session.vim")

  local block_filetypes = (
    opts ~= nil and opts.block_filetypes
  ) or { "netrw", "gitcommit" }

  local block_filenames = (
    opts ~= nil and opts.block_filenames
  ) or { "GIT_COMMIT", "COMMIT_EDITMSG" }

  vim.api.nvim_create_autocmd(
    'VimLeave',
    {
      callback = function()
        if is_plugin_blocked(block_filetypes, block_filenames) then return end
        pre_save()
        save(session_file_path)
      end
    }
  )

  vim.api.nvim_create_autocmd(
    'UIEnter',
    {
      callback = function()
        if is_plugin_blocked(block_filetypes, block_filenames) then return end
        restore(session_file_path)
        post_restore()
      end
    }
  )
end

return M
