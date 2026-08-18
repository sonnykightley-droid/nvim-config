vim.diagnostic.config({
	virtual_text = false,
	virtual_lines = { current_line = true },
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})

local signs = { Error = "✘", Warn = "▲", Hint = "⚑", Info = "»" }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, {})
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, {})
vim.keymap.set("n", "<leader>dl", function()
	local current = vim.diagnostic.config().virtual_lines
	if current then
		vim.diagnostic.config({ virtual_lines = false, virtual_text = true })
	else
		vim.diagnostic.config({ virtual_lines = { current_line = true }, virtual_text = false })
	end
end, { desc = "Toggle diagnostic display" })
