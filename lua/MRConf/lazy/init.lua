return {
    "folke/tokyonight.nvim",
    { 
		"catppuccin/nvim", 
		name = "catppuccin",
		config = function()
			vim.cmd('colorscheme catppuccin')
		end
	},
    {
        'nvim-lua/plenary.nvim',
        name = "plenary"
    },
    {
        "folke/trouble.nvim",
        config = function()
            require("trouble").setup {
                icons = false,
            }
        end
    },
	'tpope/vim-fugitive',
	'mbbill/undotree',
    'folke/zen-mode.nvim',
    'eandrju/cellular-automaton.nvim',
    'laytan/cloak.nvim',
}
