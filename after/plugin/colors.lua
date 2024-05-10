require("catppuccin").setup({
	term_colors = true})

local owl = require("little-wonder.themes.owl")


function ColorsDefaults()
	vim.cmd.colorscheme("lw-owl")
end
function ColorMyPencils(color)
	color = color or "catppuccin"
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

ColorsDefaults()
ColorMyPencils()
