return {
    "GustavEikaas/easy-dotnet.nvim",
    ft = { "cs", "fsharp", "razor", "xml" },
    cmd = "Dotnet",
    dependencies = { "nvim-lua/plenary.nvim", "mfussenegger/nvim-dap" },
    keys = {
        { "<leader>nr", "<cmd>Dotnet run<cr>", desc = "Dotnet: Run" },
        { "<leader>nd", "<cmd>Dotnet build quickfix<cr>", desc = "Dotnet: Build (errors to quickfix)" },
        { "<leader>nt", "<cmd>Dotnet testrunner<cr>", desc = "Dotnet: Test runner" },
        { "<leader>nn", "<cmd>Dotnet new<cr>", desc = "Dotnet: New project/item" },
        { "<leader>np", "<cmd>Dotnet add package<cr>", desc = "Dotnet: Add NuGet package" },
    },
    opts = {
        picker = "telescope",
        lsp = {
            config = {
                settings = {
                    ["csharp|inlay_hints"] = {
                        csharp_enable_inlay_hints_for_types = true,
                        csharp_enable_inlay_hints_for_implicit_object_creation = true,
                        dotnet_enable_inlay_hints_for_parameters = true,
                        dotnet_enable_inlay_hints_for_literal_parameters = true,
                    },
                    ["csharp|completion"] = {
                        dotnet_show_completion_items_for_unimported_namespaces = true,
                    },
                },
            },
        },
    },
}
