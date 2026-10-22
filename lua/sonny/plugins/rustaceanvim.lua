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
			-- Point at mason's real codelldb binaries rather than its `bin/`
			-- shim: on Windows that shim is a `codelldb.cmd` wrapper, which
			-- puts a cmd.exe between nvim-dap and the adapter. The layout
			-- differs per OS (checked against the v1.12.3 .vsix packages).
			-- `$MASON/packages/...` rather than `Package:get_install_path()`,
			-- which mason v2 lists as removed.
			local extension = vim.fs.joinpath(vim.fn.expand("$MASON"), "packages", "codelldb", "extension")
			local codelldb_path, liblldb_path
			if vim.fn.has("win32") == 1 then
				codelldb_path = vim.fs.joinpath(extension, "adapter", "codelldb.exe")
				liblldb_path = vim.fs.joinpath(extension, "lldb", "bin", "liblldb.dll")
			else
				codelldb_path = vim.fs.joinpath(extension, "adapter", "codelldb")
				liblldb_path = vim.fs.joinpath(
					extension,
					"lldb",
					"lib",
					vim.fn.has("mac") == 1 and "liblldb.dylib" or "liblldb.so"
				)
			end

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
