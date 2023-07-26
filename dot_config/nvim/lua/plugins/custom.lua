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
}
