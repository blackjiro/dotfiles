return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            -- 隠しファイルを表示
            hidden = true, -- .github, .claudeなどを表示
            ignored = true, -- gitignoreされたファイルも表示
          },
        },
      },
    },
  },
}
