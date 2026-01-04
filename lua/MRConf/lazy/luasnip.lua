return {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    event = "InsertEnter",
    dependencies = {
        "rafamadriz/friendly-snippets",
    },
    config = function()
        local ls = require("luasnip")

        ls.config.set_config({
            history = true,
            updateevents = "TextChanged,TextChangedI",
            enable_autosnippets = false,
        })

        -- Load vscode-style snippets (friendly-snippets)
        require("luasnip.loaders.from_vscode").lazy_load()

        local opts = { silent = true }

        -- Jump between snippet placeholders using <leader><Tab> and <leader><S-Tab>
        vim.keymap.set({ "i", "s" }, "<C-;>", function()
            if ls.jumpable(1) then
                ls.jump(1)
            end
        end, opts)

        vim.keymap.set({ "i", "s" }, "<C-,>", function()
            if ls.jumpable(-1) then
                ls.jump(-1)
            end
        end, opts)
    end,
}
