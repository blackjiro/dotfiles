return {
  { "briones-gabriel/darcula-solid.nvim" },
  { "ellisonleao/gruvbox.nvim" },
  { "sainnhe/edge" },
  { "folke/tokyonight.nvim" },
  { "everviolet/nvim" },
  { "sainnhe/sonokai" },
  { "rebelot/kanagawa.nvim" },
  { "projekt0n/github-nvim-theme" },
  {
    "pmouraguedes/neodarcula.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = false,
      dim = false,
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "neodarcula",
    },
  },
}
