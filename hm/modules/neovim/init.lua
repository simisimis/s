-- colors
vim.g.colors_name = 'gruvbox' -- theme
if vim.opt.diff:get() then
  vim.g.colors_name = 'industry'
end -- end vimdiff theme

local vimdirs = {'backup', 'tmp', 'undo'}
local swap_dir = vim.env.HOME..'/.cache/nvim/swap-files'
for _,dir in ipairs(vimdirs) do
	if vim.fn.isdirectory(vim.env.HOME.."/.cache/nvim/"..dir) == 0 then
		vim.fn.mkdir(vim.env.HOME.."/.cache/nvim/"..dir, 'p')
	end
end
vim.opt.hidden = true -- Allow buffer switching without saving
vim.opt.backup = true -- Make a backup of the file before saving
vim.opt.backupdir = vim.env.HOME..'/.cache/nvim/backup' -- Directory to write backups to (should exist)
vim.opt.directory = vim.env.HOME..'/.cache/nvim/tmp' -- No more .sw[a-z] (swap) files all over the place (should exist)
if vim.fn.has('persistent_undo') == 1 then
	vim.opt.undofile = true -- Use persistent undo file
	vim.opt.undodir = vim.env.HOME..'/.cache/nvim/undo' -- Directory to write undo files to (should exist)
end

vim.opt.clipboard = "unnamedplus" 

vim.opt.visualbell = true -- Use visual bell instead of a beep

vim.opt.tabstop = 2 -- Number of spaces that equals a tab
vim.opt.shiftwidth = 2 -- Number of spaces to shift (e.g. >> and <<) with
vim.opt.expandtab = true -- Insert spaces instead of tabs
vim.opt.listchars = vim.opt.listchars + {eol = '↲', tab = '▸ ', trail = '·'}

vim.opt.wildmode = "longest,list" -- Set shell like completion. to tab select add 'full'

vim.api.nvim_set_keymap('n', '<Tab>', ':bnext<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<S-Tab>', ':bprevious<CR>', {noremap = true})

vim.g["airline#extensions#tabline#enabled"] = 1
vim.g["airline#extensions#tabline#buffer_nr_show"] = 1
