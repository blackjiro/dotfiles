return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      gopls = {
        settings = {
          gopls = {
            buildFlags = { "-tags=linux,windows,e2e" },
          },
        },
      },
    },
  },
}
