return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      bigfile = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      picker = { enabled = true },
      notifier = { enabled = true },
      scope = { enabled = true },
      quickfile = { enabled = true },
      scroll = { enabled = true },

      --dashboard = { enabled = true },
      --explorer = { enabled = true },
      --statuscolumn = { enabled = true },
      --words = { enabled = true },
    },
  },
}
