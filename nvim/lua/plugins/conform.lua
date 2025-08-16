return {
  "stevearc/conform.nvim",
  event = "BufWritePre",   -- uncomment for format on save
  opts = require "configs.conform",
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format { async = true, lsp_fallback = true }
      end,
      mode = "",
      desc = "[F]ormat buffer",
    },
  },
}
