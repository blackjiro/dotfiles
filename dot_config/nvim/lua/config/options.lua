-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Disable LazyVim auto format
vim.g.autoformat = false

if vim.g.vscode then
  -- diaable leader key for vspacecode
  vim.g.mapleader = ""
  vim.g.clipboard = ""
end


local opt = vim.opt

opt.spelllang = { "en", "cjk" }
opt.inlay_hints.enabled = false
