local function augroup(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end

vim.api.nvim_create_autocmd("BufWritePost", {
  group = augroup("chezmoi_apply"),
  pattern = "~/.local/share/chezmoi/*",
  command = "chezmoi apply --source-path %",
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup("cd_pwd"),
  callback = function()
    local path = vim.fn.expand("%:p")
    if vim.fn.isdirectory(path) == 1 then
      vim.cmd("cd " .. path)
    end
  end,
})
