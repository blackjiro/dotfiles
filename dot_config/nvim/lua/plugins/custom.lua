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
        "flake8",
        "terraform-ls",
        "rust-analyzer",
        "lua-language-server",
        "svelte-language-server",
        "tailwindcss-language-server",
      },
    },
  },
}
