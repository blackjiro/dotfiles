return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    config = function()
      -- Set custom CSS file path
      vim.g.mkdp_markdown_css = vim.fn.expand("~/.config/nvim/markdown-preview.css")
      
      -- Other configuration options
      vim.g.mkdp_auto_start = 0 -- Don't auto-start preview
      vim.g.mkdp_auto_close = 1 -- Auto close when switching buffers
      vim.g.mkdp_refresh_slow = 0 -- Refresh preview immediately
      vim.g.mkdp_browser = "" -- Use default browser
    end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreview<cr>", desc = "Markdown Preview" },
    },
  },
}
