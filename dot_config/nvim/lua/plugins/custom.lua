return {
  {
    "folke/neodev.nvim",
    opts = { experimental = { pathStrict = true } },
    library = { plugins = { "nvim-dap-ui" }, types = true },
  },
  { "tpope/vim-rails" },
  { "mattn/emmet-vim" },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
        "flake8",
        "gopls",
        "terraform-ls",
        "solargraph",
        "rust-analyzer",
        "lua-language-server",
        "svelte-language-server",
        "tailwindcss-language-server",
      },
    },
  },
}
