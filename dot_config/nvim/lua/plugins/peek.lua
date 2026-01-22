return {
  {
    "toppair/peek.nvim",
    build = "deno task --quiet build:fast",
    config = function()
      require("peek").setup({
        theme = "light",
      })
    end,
    keys = {
      {
        "<leader>mo",
        function()
          local peek = require("peek")
          if peek.is_open() then
            peek.close()
          else
            peek.open()
          end
        end,
        desc = "Peek Toggle",
      },
    },
  },
}
