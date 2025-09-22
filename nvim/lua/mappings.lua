local map = vim.keymap.set

-- Helper function for conditional requires
local function safe_require(module)
  local ok, result = pcall(require, module)
  return ok and result or nil
end

local fzf = safe_require('fzf-lua')

-- ===============================================
-- GENERAL MAPPINGS
-- ===============================================

-- Clear search highlighting
map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })

-- Better command mode access
map("n", ";", ":", { desc = "Enter command mode" })

-- Save file
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
-- Copy Entire File
map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "general copy whole file" })


-- ===============================================
-- NAVIGATION & MOVEMENT
-- ===============================================

-- Insert mode navigation
map("i", "<C-b>", "<ESC>^i", { desc = "Move to beginning of line" })
map("i", "<C-e>", "<End>", { desc = "Move to end of line" })
map("i", "<C-h>", "<Left>", { desc = "Move left" })
map("i", "<C-l>", "<Right>", { desc = "Move right" })
map("i", "<C-j>", "<Down>", { desc = "Move down" })
map("i", "<C-k>", "<Up>", { desc = "Move up" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Switch window left" })
map("n", "<C-l>", "<C-w>l", { desc = "Switch window right" })
map("n", "<C-j>", "<C-w>j", { desc = "Switch window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Switch window up" })

-- ===============================================
-- BUFFER MANAGEMENT
-- ===============================================

map("n", "<leader>bb", "<cmd>enew<CR>", { desc = "New buffer" })
map("n", "<Tab>", function()
  require("nvchad.tabufline").next()
end, { desc = "Next buffer" })
map("n", "<S-Tab>", function()
  require("nvchad.tabufline").prev()
end, { desc = "Previous buffer" })
map("n", "<leader>bx", function()
  require("nvchad.tabufline").close_buffer()
end, { desc = "Close buffer" })

-- Copy whole file
map("n", "<leader>ya", ":%y+<CR>", { desc = "Copy entire file" })

-- ===============================================
-- DIAGNOSTICS & LSP
-- ===============================================

-- Note: [d and ]d are built-in in Neovim 0.10+
map('n', '<leader>dd', vim.diagnostic.open_float, { desc = 'Show diagnostic details' })

-- Use fzf-lua for better diagnostic navigation if available
if fzf then
  map("n", "<leader>q", fzf.diagnostics_document, { desc = "Document diagnostics" })
  map("n", "<leader>wq", fzf.diagnostics_workspace, { desc = "Workspace diagnostics" })
  map("n", "<leader>wg", fzf.lsp_live_workspace_symbols, { desc = "Workspace symbols" })
else
  -- Fallback to native diagnostics
  map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostic quickfix" })
end

-- ===============================================
-- FORMATTING & EDITING
-- ===============================================

-- Format file
map("n", "<leader>fm", function()
  require("conform").format { lsp_fallback = true }
end, { desc = "Format file" })

-- Comments (using better key combinations)
map("n", "<leader>/", "gcc", { desc = "Toggle comment", remap = true })
map("v", "<leader>/", "gc", { desc = "Toggle comment", remap = true })
map("i", "<C-/>", "<ESC>gcc", { desc = "Toggle comment", remap = true })
map({ "n", "i" }, "<C-_>", "gcc", { desc = "toggle comment", remap = true })
map("v", "<C-_>", "gc", { desc = "toggle comment", remap = true })
map({ "n", "i" }, "<C-/>", "gcc", { desc = "toggle comment", remap = true })
map("v", "<C-/>", "gc", { desc = "toggle comment", remap = true })

-- ===============================================
-- TERMINAL
-- ===============================================

-- Terminal navigation
map("t", "<C-x>", "<C-\\><C-N>", { desc = "Escape terminal mode" })

-- New terminals
map("n", "<leader>th", function()
  require("nvchad.term").new { pos = "sp" }
end, { desc = "New horizontal terminal" })

map("n", "<leader>tv", function()
  require("nvchad.term").new { pos = "vsp" }
end, { desc = "New vertical terminal" })

map("n", "<leader>tf", function()
  require("nvchad.term").new { pos = "float" }
end, { desc = "New floating terminal" })

-- Toggle terminals
map({ "n", "t" }, "<A-v>", function()
  require("nvchad.term").toggle { pos = "vsp", id = "vtoggleTerm" }
end, { desc = "Toggle vertical terminal" })

map({ "n", "t" }, "<A-h>", function()
  require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }
end, { desc = "Toggle horizontal terminal" })

map({ "n", "t" }, "<A-f>", function()
  require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
end, { desc = "Toggle floating terminal" })

-- ===============================================
-- FOLDING (UFO)
-- ===============================================

local ufo = safe_require('ufo')
if ufo then
  map('n', 'zR', ufo.openAllFolds, { desc = "Open all folds" })
  map('n', 'zM', ufo.closeAllFolds, { desc = "Close all folds" })
end

-- ===============================================
-- NVCHAD SPECIFIC
-- ===============================================

map("n", "<leader>ch", "<cmd>NvCheatsheet<CR>", { desc = "NvChad cheatsheet" })
map("n", "<leader>tt", function()
  require("nvchad.themes").open()
end, { desc = "NvChad themes" })

-- ===============================================
-- WHICH-KEY
-- ===============================================

map("n", "<leader>wK", "<cmd>WhichKey<CR>", { desc = "Show all keymaps" })
map("n", "<leader>wk", function()
  vim.cmd("WhichKey " .. vim.fn.input "WhichKey: ")
end, { desc = "Search keymaps" })
