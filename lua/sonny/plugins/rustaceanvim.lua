return {
	"mrcjkb/rustaceanvim",
	-- v9.0.0 dropped Neovim 0.11 support without a corresponding major bump
	-- (github.com/mrcjkb/rustaceanvim commit 08ad08c, "feat!: drop Neovim
	-- 0.11 support" - included in every 9.x release), so `^9` silently
	-- resolves to a version that refuses to load on 0.11.6. v8.x is the
	-- newest line that still supports it.
	version = "^8",
	lazy = false,
	ft = "rust",
	dependencies = { "mfussenegger/nvim-dap" },
	init = function()
		vim.g.rustaceanvim = function()
			local mason_registry = require("mason-registry")
			local codelldb = mason_registry.get_package("codelldb")
			local codelldb_path = codelldb:get_install_path() .. "/extension/adapter/codelldb"
			local liblldb_path = codelldb:get_install_path() .. "/extension/lldb/lib/liblldb.so"

			return {
				server = {
					default_settings = {
						["rust-analyzer"] = {
							cargo = { allFeatures = true },
							checkOnSave = true,
							check = { command = "clippy" },
							inlayHints = {
								closureReturnTypeHints = { enable = "with_block" },
								lifetimeElisionHints = { enable = "skip_trivial" },
								reborrowHints = { enable = "never" },
								typeHints = { enable = true },
							},
						},
					},
					on_attach = function(_, bufnr)
						local rt_opts = { buffer = bufnr }
						vim.keymap.set("n", "<leader>rr", function()
							vim.cmd.RustLsp("runnables")
						end, rt_opts)
						vim.keymap.set("n", "<leader>rd", function()
							vim.cmd.RustLsp("debuggables")
						end, rt_opts)
						vim.keymap.set("n", "<leader>re", function()
							vim.cmd.RustLsp("expandMacro")
						end, rt_opts)
					end,
				},
				dap = {
					adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb_path, liblldb_path),
				},
			}
		end
	end,
}
