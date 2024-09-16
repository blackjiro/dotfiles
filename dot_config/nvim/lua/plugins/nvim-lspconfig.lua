return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = {
      inlay_hints = { enabled = false },
    },
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
