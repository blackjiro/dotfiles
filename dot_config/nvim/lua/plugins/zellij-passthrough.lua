return {
  {
    "nvim-lua/plenary.nvim",
    lazy = false,
    config = function()
      -- Pass through Ctrl+t to Zellij to unlock and enter tab mode
      vim.keymap.set({ "n", "i", "v", "t" }, "<C-t>", function()
        -- Send Ctrl+t to the terminal/Zellij
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-t>", true, false, true), "n", false)
      end, { desc = "Pass Ctrl+t to Zellij for tab mode" })

      -- Pass through Ctrl+p to Zellij to unlock and enter pane mode
      vim.keymap.set({ "n", "i", "v", "t" }, "<C-p>", function()
        -- Send Ctrl+p to the terminal/Zellij
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-p>", true, false, true), "n", false)
      end, { desc = "Pass Ctrl+p to Zellij for pane mode" })
    end,
  },
}