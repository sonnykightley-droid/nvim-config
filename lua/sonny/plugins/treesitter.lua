return {
	"nvim-treesitter/nvim-treesitter",
	branch = "master",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			auto_install = true,
			sync_install = false,
			highlight = {
				enable = true,
				disable = { "markdown" },
			},
			indent = { enable = true },
		})
	end,
}
