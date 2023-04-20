return {
  { "mfussenegger/nvim-dap" },
  {
    "jay-babu/mason-nvim-dap.nvim",
    config = function()
      local dap = require("dap")
      dap.set_log_level("INFO") -- Helps when configuring DAP, see logs with :DapShowLog
      dap.configurations = {
        go = {
          {
            type = "go", -- Which adapter to use
            name = "Debug", -- Human readable name
            request = "launch", -- Whether to "launch" or "attach" to program
            program = "${file}", -- The buffer you are focused on when running nvim-dap
          },
        },
      }
      dap.adapters.go = {
        type = "server",
        port = "${port}",
        executable = {
          command = vim.fn.stdpath("data") .. "/mason/bin/dlv",
          args = { "dap", "-l", "127.0.0.1:${port}" },
        },
      }
    end,
    opts = { ensure_installed = { "delve" } },
  },
  {
    "rcarriga/nvim-dap-ui",
    config = function()
      local ui = require("dapui")
      ui.setup({
        icons = { expanded = "▾", collapsed = "▸" },
        mappings = {
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        expand_lines = vim.fn.has("nvim-0.7"),
        layouts = {
          {
            elements = {
              "scopes",
            },
            size = 0.3,
            position = "right",
          },
          {
            elements = {
              "repl",
              "breakpoints",
            },
            size = 0.3,
            position = "bottom",
          },
        },
        floating = {
          max_height = nil,
          max_width = nil,
          border = "single",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        windows = { indent = 1 },
        render = {
          max_type_length = nil,
        },
      })
    end,
  },
}
