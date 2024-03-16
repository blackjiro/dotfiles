-- reseize
vim.keymap.set("n", "<S-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<S-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<S-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<S-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- file history
vim.keymap.set("n", "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", { desc = "Curret File History" })
vim.keymap.set("n", "<leader>ge", "<cmd>DiffviewClose<cr>", { desc = "Exit diff view" })

-- only yank command register clipboards
vim.keymap.set("n", "<leader>y", '"*', { desc = "Yank to clipboard" })
vim.keymap.set("v", "<leader>y", '"*y', { desc = "Yank to clipboard" })

if vim.g.vscode then
  vim.keymap.set({"n", "v"}, "<space>", function()
    vim.cmd("call VSCodeNotify('vspacecode.space')")
  end, { noremap = true, desc = "VSpaceCode: Show VSpaceCode Menu" })
end
