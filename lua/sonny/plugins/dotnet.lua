-- Roslyn closes Razor tags through `textDocument/_vs_onAutoInsert`, a VS
-- extension that VS Code sends when `>` is typed. Neovim's client never sends
-- it (easy-dotnet only wires it up for `///`), and nvim-ts-autotag can't stand
-- in: the razor parser reads an unfinished `<div>` as an ERROR node, so there's
-- no tag for it to find.
local function setup_razor_tag_close(client, bufnr)
    vim.api.nvim_create_autocmd("InsertCharPre", {
        group = vim.api.nvim_create_augroup("sonny.razor_tag_close." .. bufnr, { clear = true }),
        buffer = bufnr,
        callback = function()
            if vim.v.char ~= ">" then
                return
            end
            -- InsertCharPre fires before the `>` is in the buffer.
            vim.schedule(function()
                if vim.api.nvim_get_current_buf() ~= bufnr then
                    return
                end
                local encoding = client.offset_encoding
                local pos = vim.lsp.util.make_position_params(0, encoding)
                local tick = vim.b[bufnr].changedtick
                client:request("textDocument/_vs_onAutoInsert", {
                    _vs_textDocument = pos.textDocument,
                    _vs_position = pos.position,
                    _vs_ch = ">",
                    _vs_options = { tabSize = vim.fn.shiftwidth(), insertSpaces = vim.bo[bufnr].expandtab },
                }, function(err, result)
                    local edit = not err and result and result._vs_textEdit
                    -- Anything typed since makes the edit's range stale.
                    if not edit or vim.b[bufnr].changedtick ~= tick or vim.api.nvim_get_current_buf() ~= bufnr then
                        return
                    end
                    -- newText is a snippet like "$0</div>"; the cursor goes where $0 is.
                    local before, after = edit.newText:match("^(.-)%$0(.*)$")
                    edit.newText = (before or edit.newText) .. (after or "")
                    vim.lsp.util.apply_text_edits({ edit }, bufnr, encoding)
                    if before and not before:find("\n") then
                        local start = edit.range.start
                        local line = vim.api.nvim_buf_get_lines(bufnr, start.line, start.line + 1, false)[1]
                        local col = vim.str_byteindex(line, encoding, start.character, false)
                        vim.api.nvim_win_set_cursor(0, { start.line + 1, col + #before })
                    end
                end, bufnr)
            end)
        end,
    })
end

return {
    "GustavEikaas/easy-dotnet.nvim",
    ft = { "cs", "fsharp", "razor", "xml" },
    cmd = "Dotnet",
    init = function()
        -- Neovim 0.11 doesn't detect .razor/.cshtml, and easy-dotnet only adds
        -- them in its setup(), which runs on the `razor` FileType.
        vim.filetype.add({ extension = { razor = "razor", cshtml = "razor" } })
        -- Nothing sets this for Razor, so `gc` fails inside @code blocks.
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "razor",
            callback = function(args)
                vim.bo[args.buf].commentstring = "@* %s *@"
            end,
        })
        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if client and client.name == "easy_dotnet" and vim.bo[args.buf].filetype == "razor" then
                    setup_razor_tag_close(client, args.buf)
                end
            end,
        })
    end,
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
