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

vim.keymap.set("n", "<M-j>", "<cmd>cnext<CR>")
vim.keymap.set("n", "<M-k>", "<cmd>cprev<CR>")

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

vim.api.nvim_create_autocmd('TermOpen', {
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.opt.number = false
    vim.opt.relativenumber = false
  end,
})

local job_id = 0
vim.keymap.set("n", "<space>st", function()
  vim.cmd.vnew()
  vim.cmd.term()
  vim.cmd.wincmd("J")
  vim.api.nvim_win_resize(0, -1, 10)

  job_id = vim.bo.channel
end)

vim.keymap.set("n", "<space>example", function()
  vim.fn.chansend(job_id, { "ls -al\r\n" })
end)
