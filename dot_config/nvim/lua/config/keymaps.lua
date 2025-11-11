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

-- Zellij integration: Pass through keybindings to unlock and switch modes
vim.keymap.set({ "n", "i", "v", "t" }, "<C-t>", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-t>", true, false, true), "n", false)
end, { desc = "Pass Ctrl+t to Zellij for tab mode" })

vim.keymap.set({ "n", "i", "v", "t" }, "<C-p>", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-p>", true, false, true), "n", false)
end, { desc = "Pass Ctrl+p to Zellij for pane mode" })

vim.keymap.set({ "n", "i", "v", "t" }, "<C-n>", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-n>", true, false, true), "n", false)
end, { desc = "Pass Ctrl+n to Zellij" })

vim.keymap.set({ "n", "i", "v", "t" }, "<C-m>", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-m>", true, false, true), "n", false)
end, { desc = "Pass Ctrl+m to Zellij" })

-- Copy relative path from working directory and line number to clipboard
vim.keymap.set("n", "<leader>cp", function()
  local filename = vim.fn.expand("%:~:.")
  local line_num = vim.fn.line(".")
  local result = "@" .. filename .. ":" .. line_num
  vim.fn.setreg("+", result)
  vim.notify("Copied: " .. result)
end, { desc = "Copy relative path from cwd:line to clipboard" })

-- Terminal mode mappings
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
