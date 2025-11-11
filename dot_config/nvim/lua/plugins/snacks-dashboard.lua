return {
  {
    "folke/snacks.nvim",
    opts = {
      explorer = {
        -- ディレクトリを開いたときにSnacksのExplorerを自動起動しない
        replace_netrw = false,
      },
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
    config = function(_, opts)
      require("snacks").setup(opts)

      -- ハイライトグループをカスタマイズ
      -- 隠しファイル（ドットファイル）は通常表示、gitignoreされたファイルのみグレーアウト
      local function setup_highlights()
        -- 隠しファイル（ドットファイル）は通常のファイルと同じ色で表示
        vim.api.nvim_set_hl(0, "SnacksPickerPathHidden", { link = "SnacksPickerFile" })
        -- gitignoreされたファイルはデフォルトのグレーアウトのまま（SnacksPickerPathIgnored）
      end

      setup_highlights()
      -- カラースキーム変更時にも適用
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("SnacksExplorerHighlights", { clear = true }),
        callback = setup_highlights,
      })
    end,
  },
}
