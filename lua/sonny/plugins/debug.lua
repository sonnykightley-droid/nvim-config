return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
		"theHamsta/nvim-dap-virtual-text",
		"mfussenegger/nvim-dap-python",
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		dapui.setup()
		require("nvim-dap-virtual-text").setup()
		require("dap-python").setup()

		-- Rust debugging (codelldb adapter + configurations) is registered by
		-- rustaceanvim itself once its LSP client attaches; see rustaceanvim.lua.

		vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
		vim.fn.sign_define(
			"DapBreakpointCondition",
			{ text = "◆", texthl = "DiagnosticWarn", linehl = "", numhl = "" }
		)
		vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DiagnosticInfo", linehl = "", numhl = "" })
		vim.fn.sign_define(
			"DapStopped",
			{ text = "▶", texthl = "DiagnosticWarn", linehl = "DapStoppedLine", numhl = "" }
		)
		vim.fn.sign_define(
			"DapBreakpointRejected",
			{ text = "✘", texthl = "DiagnosticError", linehl = "", numhl = "" }
		)

		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()
		end

		vim.keymap.set("n", "<leader>ds", dap.continue, { desc = "Debug: Start/Continue" })
		vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
		vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Debug: Step Into" })
		vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Debug: Step Over" })
		vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "Debug: Step Out" })
	end,
}
