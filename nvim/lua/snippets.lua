vim.hl.priorities.semantic_tokens = 95 -- Or any number lower than 100, treesitter's priority level

-- Appearance of diagnostics
-- vim.diagnostic.config {
--   virtual_text = {
--     prefix = "●",
--     -- Add a custom format function to show error codes
--     format = function(diagnostic)
--       local code = diagnostic.code and string.format("[%s]", diagnostic.code) or ""
--       return string.format("%s %s", code, diagnostic.message)
--     end,
--   },
--   underline = false,
--   update_in_insert = true,
--   float = {
--     source = true, -- Or "if_many"
--   },
--   -- Make diagnostic background transparent
--   on_ready = function()
--     vim.cmd "highlight DiagnosticVirtualText guibg=NONE"
--   end,
-- }

-- NvChad default diagnostic config
-- vim.diagnostic.config {
--   float = {
--     border = "single"
--   },
--   jump = {
--     float = false,
--     wrap = true
--   },
--   severity_sort = true,
--   signs = {
--     text = { "󰅙", "", "󰋼", "󰌵" }
--   },
--   underline = true,
--   update_in_insert = true,
--   virtual_lines = false,
--   virtual_text = {
--     prefix = ""
--   }
-- }

vim.diagnostic.config {
  virtual_text = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "E",
      [vim.diagnostic.severity.WARN]  = "W",
      [vim.diagnostic.severity.INFO]  = "I",
      [vim.diagnostic.severity.HINT]  = "H",
    }
  },
  underline = true,
  update_in_insert = true,
  float = {
    source = true,
    border = "rounded",
  },
  severity_sort = true,
}

vim.cmd([[
  highlight DiagnosticUnderlineError gui=undercurl guisp=#f38ba8
  highlight DiagnosticUnderlineWarn gui=undercurl guisp=#fab387
  highlight DiagnosticUnderlineInfo gui=undercurl guisp=#74c7ec
  highlight DiagnosticUnderlineHint gui=undercurl guisp=#a6e3a1
]])


-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank()
  end,
  group = highlight_group,
  pattern = "*",
})

-- Set kitty terminal padding to 0 when in nvim
vim.cmd [[
  augroup kitty_mp
  autocmd!
  au VimLeave * :silent !kitty @ set-spacing padding=default margin=default
  au VimEnter * :silent !kitty @ set-spacing padding=0 margin=0 3 0 3
  augroup END
]]
