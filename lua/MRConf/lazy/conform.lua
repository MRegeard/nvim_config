return {
  "stevearc/conform.nvim",
  opts = {},
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        lua = { "stylua" },
        go = { "gofmt" },
        zig = { "zigfmt" }, -- add zig
      },
      format_on_save = {
        timeout_ms = 1000,
        lsp_format = "fallback", -- don't use zls formatting
      },
    })

    -- Define zig formatter (runs `zig fmt <file>` in-place)
    conform.formatters.zigfmt = {
      command = "zig",
      args = { "fmt", "$FILENAME" },
      stdin = false,
    }

    -- Optional: manual command
    vim.api.nvim_create_user_command("ZigFmt", function()
      conform.format({ async = false, lsp_format = false })
    end, {})
  end,
}

