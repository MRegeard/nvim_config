require("MRConf.remap")
require("MRConf.set")
require("MRConf.language")
require("MRConf.lazy_init")

require("MRConf.codanote").setup({ filetypes = { "*" }, comment_lines_only = false })

local augroup = vim.api.nvim_create_augroup
local MRGroup = augroup('MR', {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

function R(name)
    require("plenary.reload").reload_module(name)
end

vim.filetype.add({
    extension = {
        templ = 'templ',
    }
})

autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

autocmd({ "BufWritePre" }, {
    group = MRGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

autocmd('LspAttach', {
    group = MRGroup,
    callback = function(e)
        local opts = { buffer = e.buf }
        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    end
})

vim.g.netrw_browse_split = 0
vim.g.netwr_banner = 0
vim.g.netwr_winsize = 25

-- Wrap for .tex file
local function set_tex_line_wrap(max_length)
    -- Autocommand for .tex files
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "tex",
        callback = function()
            -- Set the text width for line wrapping
            vim.opt_local.textwidth = max_length
            -- Enable line wrapping
            vim.opt_local.wrap = true
            -- Ensure line breaks occur at word boundaries
            vim.opt_local.linebreak = true
            -- Optional: Use a preferred set of break characters (adjust as needed)
            vim.opt_local.breakat = " ^I!@*-+;:,./?"
        end,
    })
end

-- Call the function with your desired max character length
set_tex_line_wrap(88)
