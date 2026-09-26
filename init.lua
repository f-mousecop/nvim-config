print("advent of hello")


require("config.lazy")

vim.opt.shiftwidth = 4
vim.opt.clipboard = "unnamedplus"

-- Enable line wrapping
vim.opt.wrap = true

-- Wrapped lines align with the start of the code line
vim.opt.breakindent = true

-- Copy the structure of the existing lines when indenting
vim.opt.copyindent = true

-- Auto insert line breaks at 80 characters
-- vim.opt.textwidth = 80

vim.keymap.set("n", "<space><space>x", "<cmd>source %<CR>")
vim.keymap.set("n", "<space>x", ":.lua<CR>")
vim.keymap.set("v", "<space>x", ":.lua<CR>")


-- Highlight when yanking (copying) text
--  Try it with 'yap' in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function()
	vim.hl.hl_op()
    end,
})

