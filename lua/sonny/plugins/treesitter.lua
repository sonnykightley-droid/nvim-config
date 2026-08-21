return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		local ensure_installed = {
			"lua",
			"vim",
			"vimdoc",
			"javascript",
			"typescript",
			"tsx",
			"jsdoc",
			"json",
			"python",
			"rust",
		}
		local installed = require("nvim-treesitter.config").get_installed("parsers")
		local to_install = vim.iter(ensure_installed)
			:filter(function(parser)
				return not vim.tbl_contains(installed, parser)
			end)
			:totable()
		if #to_install > 0 then
			require("nvim-treesitter").install(to_install)
		end

		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				if args.match == "markdown" then
					return
				end
				pcall(vim.treesitter.start)
				vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
