-- lua/codanote.lua
-- NOTE(@MRegeard): This has been vibe coded because I don't know anything about lua.
-- Seems to be working though !
-- TODO(@MRegeard): Make this its own nvim plugin ?
local M = {}

local ns = vim.api.nvim_create_namespace("Codanote")

local defaults = {
    filetypes = {},
    comment_lines_only = true,
    keywords = {
        NOTE      = { fg = "#17F105", bold = true },
        TODO      = { fg = "#FFD700", bold = true },
        IMPORTANT = { fg = "#C500ED", bold = true },
        FIXME     = { fg = "#F10C1A", bold = true },
    },
}

local function parse_filetypes(filetypes)
    if type(filetypes) == "string" then filetypes = { filetypes } end
    if type(filetypes) ~= "table" then return false, false, {} end

    local enable_all = false
    local set = {}
    for _, ft in ipairs(filetypes) do
        if ft == "*" then
            enable_all = true
        elseif type(ft) == "string" and ft ~= "" then
            set[ft] = true
        end
    end

    return enable_all or next(set) ~= nil, enable_all, set
end

local function sanitize_group_suffix(s)
    return (s:gsub("[^%w]", "_"))
end

local function normalize_keywords(user_kw, fallback_kw)
    local entries = {}

    local function add(word, spec)
        if type(word) ~= "string" or word == "" then return end

        local hl
        if type(spec) == "string" then
            hl = { fg = spec, bold = true }
        elseif type(spec) == "table" then
            hl = {
                fg        = spec.fg,
                bg        = spec.bg,
                bold      = (spec.bold ~= false),
                italic    = spec.italic,
                underline = spec.underline,
            }
        else
            return
        end

        local group = "Codanote" .. sanitize_group_suffix(word)
        table.insert(entries, { word = word, group = group, hl = hl })
    end

    local source = (user_kw ~= nil) and user_kw or fallback_kw

    if vim.islist(source) then
        for _, item in ipairs(source) do
            if type(item) == "table" then add(item.word, item) end
        end
    elseif type(source) == "table" then
        for k, v in pairs(source) do add(k, v) end
    end

    return entries
end

local function highlight_line(bufnr, row, line, entries)
    for _, entry in ipairs(entries) do
        -- Match word with optional (author) suffix, not relying on %f frontier
        local search = entry.word
        local i = 1
        while true do
            local s, e = line:find(search, i, true) -- plain search
            if not s then break end

            -- Ensure it's a whole word: char before must be non-word or start
            local before = s > 1 and line:sub(s - 1, s - 1) or " "
            local after  = line:sub(e + 1, e + 1)

            if before:match("%W") or s == 1 then
                local end_pos = e
                -- Extend through (author) if present
                if after == "(" then
                    local close = line:find(")", e + 2, true)
                    end_pos = close or #line
                end

                vim.api.nvim_buf_set_extmark(bufnr, ns, row, s - 1, {
                    end_col  = end_pos,
                    hl_group = entry.group,
                    hl_mode  = "combine",
                })
            end

            i = e + 1
        end
    end
end

local function update(bufnr, enabled, enable_all, ft_set, opts, entries)
    if not enabled then return end
    if not vim.api.nvim_buf_is_loaded(bufnr) then return end
    if vim.bo[bufnr].buftype ~= "" then return end

    if not enable_all then
        local ft = vim.bo[bufnr].filetype
        if not ft_set[ft] then return end
    end

    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    -- Try treesitter path first (comment-aware)
    local ok_parser, parser = pcall(vim.treesitter.get_parser, bufnr)
    if ok_parser and parser then
        local ok_query, query = pcall(vim.treesitter.query.parse, parser:lang(), "(comment) @c")
        if ok_query and query then
            local ok_parse, trees = pcall(function() return parser:parse() end)
            if ok_parse and trees then
                for _, tree in ipairs(trees) do
                    local root = tree:root()
                    for _, node in query:iter_captures(root, bufnr, 0, -1) do
                        -- Safe range extraction for Neovim 0.12
                        local ok_range, sr, sc, er, _ = pcall(function()
                            return node:range()
                        end)
                        if not ok_range then
                            -- fallback: get range via node row/col methods
                            sr = node:start()
                            er = node:end_()
                            sc = 0
                        end

                        for row = sr, er do
                            local line = lines[row + 1]
                            if line then
                                local first_nonspace = (line:find("%S") or (#line + 1)) - 1
                                local node_start_col = (row == sr) and sc or 0
                                local ok_line = (not opts.comment_lines_only)
                                    or (node_start_col == first_nonspace)

                                if ok_line then
                                    highlight_line(bufnr, row, line, entries)
                                end
                            end
                        end
                    end
                end
                return -- done via treesitter
            end
        end
    end

    -- Fallback: no treesitter parser available, scan all lines naively
    for row, line in ipairs(lines) do
        highlight_line(bufnr, row - 1, line, entries)
    end
end

function M.setup(user_opts)
    local opts = vim.tbl_deep_extend("force", defaults, user_opts or {})

    local enabled, enable_all, ft_set = parse_filetypes(opts.filetypes)
    local entries = normalize_keywords(opts.keywords, defaults.keywords)

    local function apply_highlights()
        for _, entry in ipairs(entries) do
            vim.api.nvim_set_hl(0, entry.group, entry.hl)
        end
    end

    apply_highlights()

    -- Re-apply after any colorscheme change
    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = apply_highlights,
    })

    vim.api.nvim_create_autocmd(
        { "BufEnter", "BufWinEnter", "TextChanged", "TextChangedI", "InsertLeave" },
        {
            callback = function(args)
                update(args.buf, enabled, enable_all, ft_set, opts, entries)
            end,
        }
    )
end

return M
