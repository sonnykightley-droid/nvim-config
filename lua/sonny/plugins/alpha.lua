return {
	"goolord/alpha-nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VimEnter",
	config = function()
		local screen = require("sonny.screen")
		require("alpha").setup(screen.opts)
	end,
}
