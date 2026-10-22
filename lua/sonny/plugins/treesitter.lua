-- I want to get the fixes in `master` branch but it only works in 0.12+
-- Currently no 0.12 for debian so have to gate
local use_main = vim.fn.has("nvim-0.12") == 1

local parsers = {
    "lua",
    "vim",
    "vimdoc",
    "javascript",
    "typescript",
    "tsx",
    "jsdoc",
    "json",
    "python",
    "rust",
    "toml",
    "c_sharp",
    "json5",
    "xml",
    "razor",
    "markdown",
    "markdown_inline",
    "sql",
    -- razor hands all markup to the html parser, which in turn injects css
    -- into <style> blocks.
    "html",
    "css",
}

-- nvim-treesitter's python indent query miscounts by one level for a `try:`
-- nested 3+ blocks deep (class -> def -> try, or def -> def -> try) -
-- `if`/`for`/etc. at the same depths are fine, only `try` is affected. Fall
-- back to Neovim's own bundled Python indentscript instead, which doesn't
-- have it.
local indent_disabled = { "python" }

-- `main` has no highlight/indent modules or auto_install; this does what
-- master's `highlight.enable`/`indent.enable` did for a buffer.
local function start(buf, lang)
    if not pcall(vim.treesitter.start, buf, lang) then
        return
    end
    if
        not vim.list_contains(indent_disabled, lang)
        and #vim.treesitter.query.get_files(lang, "indents") > 0
    then
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
end

return {
    "nvim-treesitter/nvim-treesitter",
    branch = use_main and "main" or "master",
    lazy = false,
    build = ":TSUpdate",
    -- main compiles parsers with the tree-sitter CLI, which mason installs
    -- (see lsp.lua) - load mason first so its bin dir is already on PATH.
    dependencies = use_main and { "mason-org/mason.nvim" } or nil,
    config = function(plugin)
        if not use_main then
            require("nvim-treesitter.configs").setup({
                ensure_installed = parsers,
                auto_install = true,
                highlight = {
                    enable = true,
                },
                indent = {
                    enable = true,
                    disable = indent_disabled,
                },
            })
            return
        end

        -- master compiles parsers into the plugin dir itself, and they're
        -- untracked, so switching the checkout to main leaves them behind on
        -- the runtimepath. Any language main hasn't installed yet then loads
        -- one of those with no matching queries - highlighting starts but
        -- captures nothing, and the stale parser stays loaded for the session
        -- even after main's is installed. main installs to
        -- stdpath("data")/site instead, so these are always stale here.
        for _, dir in ipairs({ "parser", "parser-info" }) do
            local path = vim.fs.joinpath(plugin.dir, dir)
            if vim.uv.fs_stat(path) then
                vim.fn.delete(path, "rf")
            end
        end

        local ts = require("nvim-treesitter")

        -- Async, and a no-op for parsers that are already installed. Once
        -- done, starts treesitter on any open buffer that was waiting on one
        -- of them. If another install is already building a parser, this
        -- waits for it rather than starting a second build.
        local function install(langs)
            ts.install(langs):await(function()
                vim.schedule(function()
                    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                        local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
                        if
                            vim.api.nvim_buf_is_loaded(buf)
                            and not vim.treesitter.highlighter.active[buf]
                            and vim.list_contains(langs, lang)
                        then
                            start(buf, lang)
                        end
                    end
                end)
            end)
        end

        if vim.fn.executable("tree-sitter") == 1 then
            install(parsers)
        else
            -- First launch on this machine: mason-tool-installer is still
            -- fetching the CLI, so wait for it instead of failing every build.
            vim.api.nvim_create_autocmd("User", {
                pattern = "MasonToolsUpdateCompleted",
                once = true,
                callback = function()
                    install(parsers)
                end,
            })
        end

        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("sonny.treesitter", { clear = true }),
            callback = function(args)
                local lang = vim.treesitter.language.get_lang(args.match)
                if not lang then
                    return
                end
                if vim.treesitter.language.add(lang) then
                    start(args.buf, lang)
                elseif vim.fn.executable("tree-sitter") == 1 and vim.list_contains(ts.get_available(), lang) then
                    -- Equivalent of master's `auto_install`.
                    install({ lang })
                end
            end,
        })
    end,
}
