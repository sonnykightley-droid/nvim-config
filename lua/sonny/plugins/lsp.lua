-- Mason's shared mason/bin/<name> shims are symlinks to the real npm-installed
-- script. That script derives its own directory from $0 to locate its JS
-- entrypoint, but invoked through the symlink, $0 is the symlink's location,
-- not the real one - it looks for its module in the wrong place. Resolving
-- to the real path before spawning sidesteps this.
local function mason_bin(name)
	local path = vim.fn.exepath(name)
	if path == "" then
		return name
	end
	return vim.uv.fs_realpath(path) or path
end

local function on_attach(args)
	local opts = { buffer = args.buf }
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- full message in a popup
end

return {
	{
		"mason-org/mason.nvim",
		opts = {},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			-- mason.nvim's own `ensure_installed` opt does nothing (no code in
			-- mason.nvim handles it) - this plugin is what actually installs
			-- non-LSP tools on startup.
			ensure_installed = { "debugpy", "codelldb", "prettierd", "rust-analyzer" },
			run_on_start = true,
		},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		opts = {
			ensure_installed = { "lua_ls", "pyright", "vtsls", "eslint" },
			automatic_enable = {
				-- vtsls replaces ts_ls, and rustaceanvim manages rust_analyzer
				-- itself; running either alongside its plain lspconfig
				-- counterpart causes duplicate/conflicting LSP clients.
				-- automatic_enable scans every *installed* mason package, not
				-- just ensure_installed, so both must be excluded here even
				-- though rust_analyzer is no longer listed above.
				exclude = { "ts_ls", "rust_analyzer" },
			},
		},
		config = function(_, opts)
			vim.api.nvim_create_autocmd("LspAttach", { callback = on_attach })

			-- Servers only advertise willRename/didRename support (used to
			-- update imports on file move/rename) if the client first
			-- declares it wants them - Neovim's defaults don't.
			vim.lsp.config("*", {
				capabilities = vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), {
					workspace = {
						fileOperations = {
							willRename = true,
							didRename = true,
						},
					},
				}),
			})

			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
					},
				},
			})

			vim.lsp.config("pyright", {
				settings = {
					python = {
						analysis = {
							typeCheckingMode = "basic",
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
						},
					},
				},
			})

			vim.lsp.config("vtsls", {
				cmd = { mason_bin("vtsls"), "--stdio" },
				settings = {
					typescript = {
						updateImportsOnFileMove = { enabled = "always" },
						suggest = { completeFunctionCalls = true },
						inlayHints = {
							parameterNames = { enabled = "literals" },
							parameterTypes = { enabled = true },
							variableTypes = { enabled = false },
							propertyDeclarationTypes = { enabled = true },
							functionLikeReturnTypes = { enabled = true },
							enumMemberValues = { enabled = true },
						},
					},
					javascript = {
						updateImportsOnFileMove = { enabled = "always" },
						suggest = { completeFunctionCalls = true },
						inlayHints = {
							parameterNames = { enabled = "literals" },
							parameterTypes = { enabled = true },
							variableTypes = { enabled = false },
							propertyDeclarationTypes = { enabled = true },
							functionLikeReturnTypes = { enabled = true },
							enumMemberValues = { enabled = true },
						},
					},
					vtsls = {
						autoUseWorkspaceTsdk = true,
						experimental = {
							completion = { enableServerSideFuzzyMatch = true },
						},
					},
				},
			})

			vim.lsp.config("eslint", {})

			require("mason-lspconfig").setup(opts)
		end,
	},
}
