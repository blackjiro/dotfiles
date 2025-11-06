return {
  {
    "sindrets/diffview.nvim",
    keys = {
      {
        "<leader>gb",
        function()
          require("git-base-diff").open_base_diff()
        end,
        desc = "Git: Diff with Base Branch",
      },
    },
    cmd = { "GitShowBase" },
    config = function()
      -- diffview.nvimの設定
      require("diffview").setup({
        keymaps = {
          file_panel = {
            ["o"] = "<Cmd>DiffviewFocusFiles<CR>", -- ファイルパネルにフォーカス
            ["<CR>"] = function()
              -- Enterでファイルを開く
              require("diffview.actions").goto_file_edit()
            end,
          },
        },
      })

      -- GitShowBaseコマンドを定義（現在のbaseブランチを表示）
      vim.api.nvim_create_user_command("GitShowBase", function()
        require("git-base-diff").show_base_branch()
      end, {
        desc = "Show base branch for current branch",
      })
    end,
  },
}
