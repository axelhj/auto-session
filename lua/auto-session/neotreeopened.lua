M = {}

function M.is_neotree_open()
  -- Implementation according to https://github.com/nvim-neo-tree/neo-tree.nvim/discussions/826#discussioncomment-5431757
  local manager = require("neo-tree.sources.manager")
  local renderer = require("neo-tree.ui.renderer")
  local state = manager.get_state("filesystem")
  return renderer.window_exists(state)
end

return M
