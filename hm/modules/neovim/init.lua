-- colors
vim.g.colors_name = 'gruvbox' -- theme
if vim.opt.diff:get() then
  vim.g.colors_name = 'industry'
end -- end vimdiff theme

local vimdirs = {'backup', 'tmp', 'undo'}
local swap_dir = vim.env.HOME .. '/.cache/nvim/swap-files'
for _,dir in ipairs(vimdirs) do
	if vim.fn.isdirectory(vim.env.HOME .. dir) == 0 then
		vim.fn.mkdir(dir, 'p')
	end
end
vim.o.hidden = true -- Allow buffer switching without saving
vim.o.backup = true -- Make a backup of the file before saving
vim.o.backupdir = vim.env.HOME .. '/.cache/nvim/backup' -- Directory to write backups to (should exist)
vim.o.directory = vim.env.HOME .. '/.cache/nvim/tmp' -- No more .sw[a-z] (swap) files all over the place (should exist)
if vim.fn.has('persistent_undo') == 1 then
	vim.o.undofile = true -- Use persistent undo file
	vim.o.undodir = vim.env.HOME .. '/.cache/nvim/undo' -- Directory to write undo files to (should exist)
	vim.o.undolevels = 1000 -- Maximum number of changes that can be undone
	vim.o.undoreload = 10000 -- Maximum number of lines to save for undo on buffer reload
end

vim.o.tabstop = 2 -- Number of spaces that equals a tab
vim.o.shiftwidth = 2 -- Number of spaces to shift (e.g. >> and <<) with
vim.o.expandtab = true -- Insert spaces instead of tabs
vim.o.autoindent = true -- Automatically indent to the previous lines' indent level
vim.opt.listchars = vim.opt.listchars + {eol = '↲', tab = '▸ ', trail = '·'}
