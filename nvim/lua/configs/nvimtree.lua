dofile(vim.g.base46_cache .. "nvimtree")

return {
  filters = { dotfiles = false },
  disable_netrw = true,
  hijack_cursor = true,
  sync_root_with_cwd = true,
  hijack_unnamed_buffer_when_opening = true,
  reload_on_bufenter = true,
  update_focused_file = {
    enable = true,
    update_root = false,
  },
  -- follow_current_file = {
  --   enabled = true,
  --   leave_dirs_open = false,
  -- },
  view = {
    width = 30,
    preserve_window_proportions = true,
  },
  renderer = {
    root_folder_label = false,
    highlight_git = true,
    indent_markers = { enable = true },
    icons = {
      glyphs = {
        default = "󰈚",
        folder = {
          default = "",
          empty = "",
          empty_open = "",
          open = "",
          symlink = "",
        },
        git = { unmerged = "" },
      },
    },
  },
}
