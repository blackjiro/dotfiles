return {
  { "tpope/vim-rails" },
  { "mattn/emmet-vim" },
  { "sindrets/diffview.nvim" },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
        "lua-language-server",
        "svelte-language-server",
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- <leader>ff を上書きして隠しファイルを表示
      {
        "<leader>ff",
        function()
          require("telescope.builtin").find_files({
            hidden = true,
            find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
          })
        end,
        desc = "Find Files (including hidden)",
      },
    },
  },
  {
    "greggh/claude-code.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "folke/which-key.nvim",
    },
    config = function()
      require("claude-code").setup({
        -- You can configure options here if needed
      })
    end,
    keys = {
      { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Claude Code" },
      { "<leader>ca", "<cmd>ClaudeCodeAccept<cr>", desc = "Accept Claude Code" },
      { "<leader>cr", "<cmd>ClaudeCodeReject<cr>", desc = "Reject Claude Code" },
    },
  },
}
