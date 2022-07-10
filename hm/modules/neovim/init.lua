-- Use space as the leader.
vim.g.mapleader = " "
-- Eliminate delays.
vim.opt.timeout = false
vim.opt.timeoutlen = 0
vim.opt.ttimeout = false
vim.opt.ttimeoutlen = 0
-- Manage buffs.
vim.api.nvim_set_keymap("n", "<leader><S-Tab>", ":bprevious<CR>", {})
vim.api.nvim_set_keymap("n", "<leader><Tab>", ":bnext<CR>", {})
-- Manage tabs.
vim.api.nvim_set_keymap("n", "<S-Tab>", ":tabprevious<CR>", {})
vim.api.nvim_set_keymap("n", "<Tab>", ":tabnext<CR>", {})
vim.api.nvim_set_keymap("n", "<leader><C-w>", ":tabclose<CR>", {})
vim.api.nvim_set_keymap("n", "<leader><C-t>", ":tabnew<CR>", {})
vim.o.completeopt = 'menuone,noinsert,noselect'
-- vim.opt.shortmess:append("s")
-- Autoreload files changed outside vim.
vim.opt.autoread = true

-- Clear search highlighting on escape.
vim.api.nvim_set_keymap("n", "<Esc>", ":noh<CR><Esc>", { noremap = true })

-- Set default split direction.
vim.opt.splitright = true
-- vim.opt.splitbelow = true

-- colors
vim.opt.background = 'dark'
vim.g.colors_name = 'slate' -- theme
if vim.opt.diff:get() then
  vim.g.colors_name = 'industry'
end -- end vimdiff theme
vim.cmd [[
  hi Pmenu ctermfg=187 ctermbg=240 guifg=#d8caac guibg=#505a60
  hi PmenuSel ctermbg=238 guibg=#444444
  hi PmenuSel ctermfg=255 guifg=#EEEEEE
  hi DiffAdd ctermbg=22
  hi DiffChange ctermbg=58
  hi DiffDelete ctermbg=52
]]
-- 
local nvim_lsp = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

nvim_lsp.rust_analyzer.setup {
	capabilities = capabilities,
}
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
	vim.lsp.diagnostic.on_publish_diagnostics, {
		virtual_text = true,
		signs = false,
		update_in_insert = true,
	}
)
-- lsp hover pop up text
vim.api.nvim_set_keymap("n", "<leader>u", ':lua vim.lsp.buf.hover()<CR>', {})

-- lsp rename variables
vim.api.nvim_set_keymap("n", "<leader>n", ':lua vim.lsp.buf.rename()<CR>', {})

local cmp = require('cmp')
cmp.setup({
  -- Enable LSP snippets
  snippet = {
    expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    -- Add arrows
    ['<Up>'] = cmp.mapping.select_prev_item(),
    ['<Down>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    })
  },

  -- Installed sources
  sources = {
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'path' },
    { name = 'buffer' },
  },
})
vim.g.rustfmt_autosave = 1
require('rust-tools').setup({})

-- plugin settings
vim.wo.signcolumn = 'yes'
--vim.g.gitgutter_enabled = 1
--vim.g.gitgutter_preview_win_floating = 1
--vim.g.gitgutter_override_sign_column_highlight=1
--vim.g.gitgutter_highlight_lines=0

-- mappings
--vim.api.nvim_set_keymap('n', '<leader>gg', ':GitGutterToggle<CR>', {})
--vim.api.nvim_set_keymap('n', '<leader>gh', ':GitGutterLineHighlightsToggle \\| :GitGutterLineNrHighlightsToggle<CR>', {})

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

-- Enable smart indentation.
vim.opt.smartindent = true
vim.opt.tabstop = 2 -- Number of spaces that equals a tab
vim.opt.shiftwidth = 2 -- Number of spaces to shift (e.g. >> and <<) with
vim.opt.expandtab = true -- Insert spaces instead of tabs
vim.opt.listchars = vim.opt.listchars + {eol = '↲', tab = '▸ ', trail = '·'}

vim.opt.wildmode = "longest,list" -- Set shell like completion. to tab select add 'full'

--vim.api.nvim_set_keymap('n', '<Tab>', ':bnext<CR>', {noremap = true})
--vim.api.nvim_set_keymap('n', '<S-Tab>', ':bprevious<CR>', {noremap = true})

-- Disable folding
vim.opt.foldenable = false

--vim.g["airline#extensions#tabline#enabled"] = 1
--vim.g["airline#extensions#tabline#buffer_nr_show"] = 1
require'hop'.setup()
require'lualine'.setup {
  extensions = {},
  options = {
    disabled_filetypes = {},
    theme = "jellybeans"
  },
  sections = {
    lualine_a = { "hostname", "windows" },
    lualine_b = { "branch", "diff" },
    lualine_c = { "filename" },
    lualine_x = { "mode", "filetype" },
    lualine_y = { "progress" },
    lualine_z = { "location" }
  }
}
vim.api.nvim_set_keymap("n", "<leader>j", '<cmd>lua require("hop").hint_words()<CR>', {})
vim.api.nvim_set_keymap("n", "<leader>l", '<cmd>lua require("hop").hint_lines()<CR>', {})
vim.api.nvim_set_keymap("v", "<leader>j", '<cmd>lua require("hop").hint_words()<CR>', {})
vim.api.nvim_set_keymap("v", "<leader>l", '<cmd>lua require("hop").hint_lines()<CR>', {})
