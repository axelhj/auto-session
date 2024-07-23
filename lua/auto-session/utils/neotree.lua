M = {}

local replace_termcodes = require"auto-session.utils.feedkeys".replace_termcodes

function M.is_neotree_open()
  -- Implementation according to https://github.com/nvim-neo-tree/neo
  --  -tree.nvim/discussions/826#discussioncomment-5431757
  local manager = require("neo-tree.sources.manager")
  local renderer = require("neo-tree.ui.renderer")
  local state = manager.get_state("filesystem")
  return renderer.window_exists(state)
end

function M.neotree_toggle(state_variable_name)
  if vim.g[state_variable_name] then
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

return M
