vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

opt.relativenumber = true
opt.number = true

-- tab & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

opt.wrap = false

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if mixed case in search, assumes case-sensitive

opt.cursorline = true

-- termguicolors for certain color schemes to work correctly
-- only works with true color terminals
opt.termguicolors = true
opt.background = "dark" -- default to dark if possible
opt.signcolumn = "yes" -- so text doesnt shift

opt.backspace = "indent,eol,start"

opt.clipboard:append("unnamedplus") -- use system clipboard as default register

opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

