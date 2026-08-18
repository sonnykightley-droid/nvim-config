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
                        if vim.o.columns < 150 then  -- check for splitscreen
                            require("neo-tree.command").execute({ action = "close" })
                        end
                    end,
                },
            },
            default_component_configs = {
                indent = {
                    with_expanders = false
                }
            }
        })
    end,
}
