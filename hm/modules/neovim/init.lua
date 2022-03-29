-- Use space as the leader.
vim.g.mapleader = " "
-- Eliminate delays.
vim.opt.timeout = false
vim.opt.timeoutlen = 0
vim.opt.ttimeout = false
vim.opt.ttimeoutlen = 0
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
vim.opt.splitbelow = true
-- 
local cmp = require'cmp'
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
    -- Add tab support
    --['<S-Tab>'] = cmp.mapping.select_prev_item(),
    --['<Tab>'] = cmp.mapping.select_next_item(),
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
local nvim_lsp = require'lspconfig'
local opts = {
  tools = { -- rust-tools options
    autoSetHints = true,
    hover_with_actions = true,
    inlay_hints = {
      show_parameter_hints = false,
      parameter_hints_prefix = "",
      other_hints_prefix = "",
    },
  },
  -- all the opts to send to nvim-lspconfig
  -- these override the defaults set by rust-tools.nvim
  -- see https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer
  server = {
    -- on_attach is a callback called when the language server attachs to the buffer
    -- on_attach = on_attach,
    settings = {
      -- to enable rust-analyzer settings visit:
      -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
      ["rust-analyzer"] = {
        -- enable clippy on save
        checkOnSave = {
          command = "clippy"
        },
      }
    }
  },
}

require('rust-tools').setup(opts)

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

-- Enable smart indentation.
vim.opt.smartindent = true
vim.opt.tabstop = 2 -- Number of spaces that equals a tab
vim.opt.shiftwidth = 2 -- Number of spaces to shift (e.g. >> and <<) with
vim.opt.expandtab = true -- Insert spaces instead of tabs
vim.opt.listchars = vim.opt.listchars + {eol = '↲', tab = '▸ ', trail = '·'}

vim.opt.wildmode = "longest,list" -- Set shell like completion. to tab select add 'full'

--vim.api.nvim_set_keymap('n', '<Tab>', ':bnext<CR>', {noremap = true})
--vim.api.nvim_set_keymap('n', '<S-Tab>', ':bprevious<CR>', {noremap = true})

vim.g["airline#extensions#tabline#enabled"] = 1
vim.g["airline#extensions#tabline#buffer_nr_show"] = 1
