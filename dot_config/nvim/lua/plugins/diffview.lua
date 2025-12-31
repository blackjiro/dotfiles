return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File History (current)" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "File History (all)" },
    { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Diffview Close" },
  },
  opts = {
    view = {
      default = {
        layout = "diff2_horizontal",
      },
      file_history = {
        layout = "diff2_horizontal",
      },
    },
  },
}
