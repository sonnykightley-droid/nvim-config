return {
	"saghen/blink.cmp",
	dependencies = { "rafamadriz/friendly-snippets" },
	version = "1.*", -- stable version at time of setup
	opts = {
		keymap = { preset = "default" },
		appearance = { nerd_font_variant = "mono" },
		completion = {
			documentation = {
				auto_show = true,
				-- rust-analyzer's docs often embed rustdoc code examples, and
				-- blink's docs-window highlighter hits a real upstream bug on
				-- them (saghen/blink.cmp#2474: treesitter.lua:196 "attempt to
				-- call method 'range' (a nil value)"). The fix there is
				-- nvim-treesitter's `main` branch, which treesitter.lua only
				-- uses on Neovim 0.12+. On 0.11 (still on `master`), disabling
				-- just the docs window's syntax highlighting avoids it; docs
				-- still show, just as plain text.
				treesitter_highlighting = vim.fn.has("nvim-0.12") == 1,
			},
			accept = {
				auto_brackets = {
					enabled = true,
				},
			},
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},
		fuzzy = { implementation = "prefer_rust" },
	},
	opts_extend = { "sources.default" },
}
