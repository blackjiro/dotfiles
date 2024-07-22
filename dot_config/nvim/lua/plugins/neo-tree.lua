return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      sources = { "filesystem", "buffers", "diagnostics" },
      filesystem = {
        show_hidden = false,
        hide_dotfiles = true,
        hide_gitignored = true,
      },
    },
  },
}
