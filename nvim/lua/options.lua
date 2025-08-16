-- require "nvchad.options"
--
-- local opt = vim.opt
-- local o = vim.o
local g = vim.g
--
-- -------------------------------------- options ------------------------------------------
-- o.laststatus = 3
-- o.showmode = false
--
-- o.clipboard = "unnamedplus"
-- o.cursorline = true
-- o.cursorlineopt = "number"
--
-- -- Indenting
-- o.expandtab = true
-- o.shiftwidth = 2
-- o.smartindent = true
-- o.tabstop = 2
-- o.softtabstop = 2
--
-- -- opt.fillchars = { eob = " " }
-- o.ignorecase = true
-- o.smartcase = true
-- o.mouse = "a"
--
-- -- Numbers
-- o.number = true
-- o.numberwidth = 2
-- o.ruler = false
--
-- -- disable nvim intro
-- opt.shortmess:append "sI"
--
-- o.signcolumn = "yes"
-- o.splitbelow = true
-- o.splitright = true
-- o.timeoutlen = 400
-- o.undofile = true
--
-- -- interval for writing swap file to disk, also used by gitsigns
-- o.updatetime = 250
--
-- -- go to previous/next line with h,l,left arrow and right arrow
-- -- when cursor reaches end/beginning of line
-- opt.whichwrap:append "<>[]hl"
--
-- -- disable some default providers
g.loaded_node_provider = 0
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0
--
-- -- add binaries installed by mason.nvim to path
local is_windows = vim.fn.has "win32" ~= 0
local sep = is_windows and "\\" or "/"
local delim = is_windows and ";" or ":"
vim.env.PATH = table.concat({ vim.fn.stdpath "data", "mason", "bin" }, sep) .. delim .. vim.env.PATH
--
-- -- Enable break indent
-- vim.opt.breakindent = true
--
-- -- Save undo history
-- vim.opt.undofile = true
--
-- -- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
-- vim.opt.ignorecase = true
-- vim.opt.smartcase = true
--
-- -- Decrease update time
-- vim.opt.updatetime = 250
--
-- -- Decrease mapped sequence wait time
-- -- Displays which-key popup sooner
-- vim.opt.timeoutlen = 300
--
-- -- Configure how new splits should be opened
-- vim.opt.splitright = true
-- vim.opt.splitbelow = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.mouse = "a"

vim.opt.showmode = false

vim.opt.clipboard = "unnamedplus"

vim.opt.breakindent = true

vim.opt.undofile = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.signcolumn = "yes"

vim.opt.updatetime = 250

vim.opt.timeoutlen = 300

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.inccommand = "split"

vim.opt.cursorline = true

vim.opt.sts = 2
vim.opt.sw = 2
vim.opt.et = true
vim.opt.wm = 10
vim.opt.ts = 2


-- vim.o.foldcolumn = '1' -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true
