-- Zig docs (0.15.2) dark-mode inspired colorscheme for Neovim.

local p = {
  bg      = "#121212",
  fg      = "#cccccc",
  dim     = "#aaaaaa",
  link    = "#8888ff",

  code_bg = "#222222",
  border  = "#444444",

  kw      = "#eeeeee",
  str     = "#22ee55", -- "#2e5" expanded
  builtin = "#ff894c",
  com     = "#aaaa77", -- "#aa7" expanded
  fn      = "#b1a0f8",
  ty      = "#6688ff", -- "#68f" expanded
  num     = "#ff8080",

  accent  = "#b27306",
  black   = "#000000",
}

local function hl(group, spec)
  vim.api.nvim_set_hl(0, group, spec)
end

local function link(group, target)
  hl(group, { link = target })
end

vim.cmd("hi clear")
vim.cmd("syntax reset")
vim.o.termguicolors = true
vim.o.background = "dark"
vim.g.colors_name = "zigdoc"

-- UI
hl("Normal", { fg = p.fg, bg = p.bg })
hl("NormalFloat", { fg = p.fg, bg = p.code_bg })
hl("FloatBorder", { fg = p.border, bg = p.code_bg })
hl("WinSeparator", { fg = p.border })

hl("LineNr", { fg = p.dim })
hl("CursorLineNr", { fg = p.kw })
hl("CursorLine", { bg = "#1a1a1a" })

hl("Visual", { fg = p.black, bg = p.accent })
hl("Search", { fg = p.black, bg = p.accent })
hl("IncSearch", { fg = p.black, bg = p.accent })
hl("MatchParen", { fg = p.kw, bg = p.border })

hl("Pmenu", { fg = p.fg, bg = p.code_bg })
hl("PmenuSel", { fg = p.black, bg = p.accent })

hl("Underlined", { fg = p.link, underline = true })

-- Basic syntax (fallback)
hl("Comment", { fg = p.com, italic = true })
hl("String", { fg = p.str })
hl("Number", { fg = p.num })
hl("Boolean", { fg = p.num })
hl("Constant", { fg = p.num })

hl("Keyword", { fg = p.kw, bold = true })
hl("Operator", { fg = p.kw })
hl("Function", { fg = p.fn, bold = true })
hl("Type", { fg = p.ty, bold = true })

hl("Special", { fg = p.builtin })
hl("PreProc", { fg = p.builtin })

-- Tree-sitter
hl("@comment", { fg = p.com, italic = true })
hl("@string", { fg = p.str })
hl("@number", { fg = p.num })
hl("@boolean", { fg = p.num })

hl("@keyword", { fg = p.kw, bold = true })
hl("@keyword.return", { fg = p.kw, bold = true })
hl("@operator", { fg = p.kw })

hl("@function", { fg = p.fn, bold = true })
hl("@function.builtin", { fg = p.builtin })
hl("@constant.builtin", { fg = p.builtin })

hl("@type", { fg = p.ty, bold = true })
hl("@type.builtin", { fg = p.ty, bold = true })

-- Neovim renamed some captures; support both
hl("@text.uri", { fg = p.link, underline = true })
hl("@markup.link.url", { fg = p.link, underline = true })

-- LSP semantic tokens: make them consistent with TS
link("@lsp.type.keyword", "@keyword")
link("@lsp.type.operator", "@operator")
link("@lsp.type.comment", "@comment")
link("@lsp.type.string", "@string")
link("@lsp.type.number", "@number")
link("@lsp.type.boolean", "@boolean")
link("@lsp.type.function", "@function")
link("@lsp.type.method", "@function")
link("@lsp.type.type", "@type")
link("@lsp.type.class", "@type")
link("@lsp.type.struct", "@type")
link("@lsp.type.enum", "@type")
link("@lsp.type.interface", "@type")
link("@lsp.type.namespace", "@type")

-- Default library (often stdlib): color like "builtin"
hl("@lsp.typemod.function.defaultLibrary", { fg = p.builtin })
hl("@lsp.typemod.variable.defaultLibrary", { fg = p.builtin })
hl("@lsp.typemod.type.defaultLibrary", { fg = p.ty })

-- Telescope
hl("TelescopeNormal", { fg = p.fg, bg = p.code_bg })
hl("TelescopeBorder", { fg = p.border, bg = p.code_bg })
hl("TelescopePromptNormal", { fg = p.fg, bg = p.code_bg })
hl("TelescopePromptBorder", { fg = p.border, bg = p.code_bg })
hl("TelescopePromptTitle", { fg = p.black, bg = p.accent })
hl("TelescopeResultsTitle", { fg = p.black, bg = p.accent })
hl("TelescopePreviewTitle", { fg = p.black, bg = p.accent })
hl("TelescopeSelection", { fg = p.black, bg = p.accent })
hl("TelescopeSelectionCaret", { fg = p.black, bg = p.accent, bold = true })
hl("TelescopeMatching", { fg = p.link, bold = true })
hl("TelescopePromptPrefix", { fg = p.builtin, bold = true })

