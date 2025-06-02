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
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        -- file_ignore_patternsを空にして、デフォルトの無視パターンを無効化
        file_ignore_patterns = { "^.git/" },
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
          "--no-ignore",
          "--glob",
          "!.git/*",
        },
      },
      pickers = {
        find_files = {
          hidden = true,
          no_ignore = true,
          no_ignore_parent = true,
          find_command = { "rg", "--files", "--hidden", "--no-ignore", "--glob", "!.git/*" },
        },
        live_grep = {
          additional_args = function()
            return { "--hidden", "--no-ignore" }
          end,
        },
      },
    },
  },
}
