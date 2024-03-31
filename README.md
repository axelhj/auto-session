# auto-session

This is a very simple auto-session-manager. There is one session, located at `$XDG_DATA_HOME/sessions/session.vim`. ShaDa and SessionOpts are modified.

On
 - VimLeave, mksession! is invoked. Shada is forcefully saved.
 - UIEnter, the session file is sourced. NVim will normally have restored shada at this point.

## Package managers

### Lazy.nvim

```lua
return {
  "axelhj/auto-session",
  config = true,
  dependencies = {
    "akinsho/toggleterm.nvim',
    "nvim-neo-tree/neo-tree.nvim",
  }
}
```

(config = true to avoid lazy-loading such that UIEnter would be missed, the toggleterm & neo-tree integrations are non-optional.)

## Configuration

if `{ sessionoptions = string? }` is set, then vim.o.sessionoptions will be set to that value instead of the plugin default value.

if `{ shada = string? }` is set, then vim.o.shada will be set to that value instead of the plugin default value.

if `{ session_file_path = string? }` is set, then the session-file will be created with this name & path instead of the plugin default value.

if `{ block_filetypes = table of string` } is set, then if the opened buffer when the plugin is loaded matches any of these filetypes, then the plugin will not load or persist any sessions or buffers. This means that by default, if a ft of netrw or gitcommit is loaded (eg. vim was opened by git or sent a path as the first argument), then the plugin will do nothing. In this case persisting any options, buffers, windows or tabs buffer will essentially persist the one-off session which is unlikely to be desired (morefold so when considering a git commit message composition buffer).

if `{ block_filenames = table of string` } is set, then if the opened buffer when the plugin is loaded has this filename, the plugin will not load or persist any settings. This means that by default, if Neovim was opened by eg git or sent a path as the first argument), then the plugin will do nothing. This is used to handle extension-less files such as those used by git or when loading NETRW (directories are extensionless. If eg. `nvim ./my_dir/` is opened in Neovim and netrw is enabled this directory will be loaded and the netrw ft is not always set. In such cases the buffername may have been set as netrw and restoring a buffer will essentially block the usage of Neovim to load a single file or directory which is unlikely to be desired.

### Defaults
  - By default, block_filetypes include "netrw" and "gitcommit".

  - By default, block_filenames include "GIT_COMMIT" and "COMMIT_EDITMSG".

## Behaviours

If the vim.fn.argc() returns a value other than zero, the plugin will do nothing. This is so that a filetree & possibly 20 buffers are not opened simply because some .txt or .md or random config-file was opened from a shell. This is ensured by a pre-save hook.

The block_filetypes or block_filesnames-options have sort of the same raison d'être.

### Hooks

- Before saving, a hook is executed that makes sure that for each tab-page any toggleterm-terminals are closed. A mark is set and restored such that closing a toggle-term buffer in vim-tab N+1 restores the current tab to N after closing toggle-term so that the same tab as was last opened when invoking eg. `:qa` is the one that Neovim presents when neovim is opened anew. A global value is persisted through SHADA. It has th name `NEOTREE_LAST_OPENED`. It will be set to one before closing Neotree if neotree is opened in the current buffer.

- After loading the session state, a hook is executed that will open Neotree if `NEOTREE_LAST_OPENED` has the value 1. If/when Neotree is set to follow the cwd and vim-rooter is used, the previously edited file will be focused in the Neotree automatically and therefore it is not within the scope of this plugin to restore any Neotree session even if it might be possible.

## Inspiration

I was initially using rmagatti/auto-session but realized that when using vim-rooter, persisting more than one session is just cumbersome.

I tried to keep the plugin as simple as possible, but still I see some ShaDa file corruptions possibly related to this plugin. It happens every other week in quite normal usage that the shadafile is no longer working normally. It appears to be a sideeffect of running multiple Neovim sessions locally although I don't have a repro available.
