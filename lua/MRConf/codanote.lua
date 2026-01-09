-- lua/codanote.lua
-- NOTE(@MRegeard): This has been vibe coded because I don't know anything about lua.
-- Seems to be working though !
-- TODO(@MRegeard): Make this its own nvim plugin ?
local M = {}

local ns = vim.api.nvim_create_namespace("Codanote")

local defaults = {
    -- Disabled by default. Provide e.g. { "zig", "lua" } or { "*" } for all.
    filetypes = {},

    -- Only highlight if the line is a "comment line" (comment begins at first
    -- non-space). Set false to highlight inside comments even after code.
    comment_lines_only = true,

    -- Default keywords (customisable by the user)
    keywords = {
        NOTE = { fg = "#17F105", bold = true },
        TODO = { fg = "#F10C1A", bold = true },
        IMPORTANT = { fg = "#C500ED", bold = true },
        FIXME = { fg = "#FFD700", bold = true },
    },
}

local function parse_filetypes(filetypes)
    if type(filetypes) == "string" then filetypes = { filetypes } end
    if type(filetypes) ~= "table" then return false, false, nil end

    local enable_all = false
    local set = {}
    for _, ft in ipairs(filetypes) do
        if ft == "*" then
            enable_all = true
        elseif type(ft) == "string" and ft ~= "" then
            set[ft] = true
        end
    end

    local enabled = enable_all or (next(set) ~= nil)
    return enabled, enable_all, set
end

local function escape_lua_pat(s)
    -- Escape Lua pattern magic chars
    return (s:gsub("([%%%^%$%(%)%.%[%]%*%+%-%?])", "%%%1"))
end

local function sanitize_group_suffix(s)
    -- Highlight group names should be simple; replace non-alnum with '_'
    return (s:gsub("[^%w]", "_"))
end

local function normalize_keywords(user_kw, fallback_kw)
    -- Returns an array of entries:
    -- { word=..., group=..., hl={...}, pat=... }
    local entries = {}

    local function add(word, spec)
        if type(word) ~= "string" or word == "" then return end

        local hl = nil
        if type(spec) == "string" then
            -- If user passes just a color, default to bold=true
            hl = { fg = spec, bold = true }
        elseif type(spec) == "table" then
            hl = {
                fg = spec.fg,
                bg = spec.bg,
                bold = (spec.bold ~= false), -- default bold unless explicitly false
                italic = spec.italic,
                underline = spec.underline,
            }
        else
            return
        end

        local group = "Codanote" .. sanitize_group_suffix(word)

        -- IMPORTANT: build Lua frontier pattern by concatenation (NOT string.format)
        local pat = "%f[%w]" .. escape_lua_pat(word) .. "%f[%W]"

        table.insert(entries, { word = word, group = group, hl = hl, pat = pat })
    end

    if user_kw == nil then
        for k, v in pairs(fallback_kw) do add(k, v) end
        return entries
    end

    if vim.islist(user_kw) then
        for _, item in ipairs(user_kw) do
            if type(item) == "table" then
                add(item.word, item)
            end
        end
    elseif type(user_kw) == "table" then
        for k, v in pairs(user_kw) do
            add(k, v)
        end
    end

    return entries
end

local function highlight_one(bufnr, row, line, entry)
    local i = 1
    while true do
        local s, e = line:find(entry.pat, i)
        if not s then break end

        local end_pos = e -- highlight just KEY by default

        -- If immediately followed by "(...)", extend highlight through ')'
        if line:sub(e + 1, e + 1) == "(" then
            local close = line:find(")", e + 2, true)
            if close then
                end_pos = close
            else
                end_pos = #line -- no closing ")", highlight to end of line
            end
        end

        vim.api.nvim_buf_set_extmark(bufnr, ns, row, s - 1, {
            end_col = end_pos,
            hl_group = entry.group,
            hl_mode = "combine",
        })

        i = end_pos + 1
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

    local ok_parser, parser = pcall(vim.treesitter.get_parser, bufnr)
    if not ok_parser or not parser then return end

    local lang = parser:lang()
    local ok_query, query = pcall(vim.treesitter.query.parse, lang, "(comment) @c")
    if not ok_query then return end

    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local trees = parser:parse()

    for _, tree in ipairs(trees) do
        local root = tree:root()

        for _, node in query:iter_captures(root, bufnr, 0, -1) do
            local sr, sc, er, _ = node:range()

            for row = sr, er do
                local line = lines[row + 1]
                if line then
                    local first_nonspace = line:find("%S") or (#line + 1)
                    local node_start_col = (row == sr) and sc or 0

                    local ok_line = true
                    if opts.comment_lines_only then
                        ok_line = (node_start_col == (first_nonspace - 1))
                    end

                    if ok_line then
                        for _, entry in ipairs(entries) do
                            highlight_one(bufnr, row, line, entry)
                        end
                    end
                end
            end
        end
    end
end

function M.setup(user_opts)
    local opts = vim.tbl_deep_extend("force", defaults, user_opts or {})

    local enabled, enable_all, ft_set = parse_filetypes(opts.filetypes)
    local entries = normalize_keywords(opts.keywords, defaults.keywords)

    -- define highlight groups
    for _, entry in ipairs(entries) do
        vim.api.nvim_set_hl(0, entry.group, entry.hl)
    end

    vim.api.nvim_create_autocmd(
        { "BufEnter", "BufWinEnter", "TextChanged", "TextChangedI", "InsertLeave" },
        {
            callback = function(args)
                update(args.buf, enabled, enable_all, ft_set or {}, opts, entries)
            end,
        }
    )
end

return M
