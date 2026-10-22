local function on_file_renamed(args)
    local files = {
        {
            oldUri = vim.uri_from_fname(args.source),
            newUri = vim.uri_from_fname(args.destination),
        },
    }
    for _, client in ipairs(vim.lsp.get_clients()) do
        if client:supports_method("workspace/willRenameFiles") then
            local resp = client:request_sync("workspace/willRenameFiles", { files = files }, 5000, 0)
            if resp and resp.result then
                vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
            end
        end
        if client:supports_method("workspace/didRenameFiles") then
            client:notify("workspace/didRenameFiles", { files = files })
        end
    end
end

return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    config = function()
        vim.keymap.set("n", "<C-n>", ":Neotree filesystem reveal left<CR>")
        require("neo-tree").setup({
            event_handlers = {
                {
                    event = "file_opened",
                    handler = function(file_path)
                        require("neo-tree.command").execute({ action = "close" })
                    end,
                },
                { -- update file inmports on rename
                    event = "file_renamed",
                    handler = on_file_renamed,
                },
                { -- update imports on file move
                    event = "file_moved",
                    handler = on_file_renamed,
                }
            },
            default_component_configs = {
                indent = {
                    with_expanders = false
                }
            }
        })
    end,
}
