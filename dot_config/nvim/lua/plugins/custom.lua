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
            find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*", "--glob", "!node_modules/*" },
          })
        end,
        desc = "Find Files (including hidden)",
      },
    },
  },
}
