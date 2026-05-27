return {
    {
        "romus204/tree-sitter-manager.nvim",
        lazy = false,
        config = function()
            require("tree-sitter-manager").setup({
                ensure_installed = {
                    "lua",
                    "c",
                    "cpp",
                    "rust",
                    "bash",
                    "python",
                    "yaml",
                    "toml",
                    "zig",
                    "gitignore",
                    "vim",
                    "markdown",
                    "markdown_inline",
                    "latex",
                },
                highlight = true,
                auto_install = true,
            })
        end,
    },
}
