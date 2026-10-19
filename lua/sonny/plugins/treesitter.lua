return {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = {
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
            },
            auto_install = true,
            highlight = {
                enable = true,
            },
            indent = {
                enable = true,
                -- nvim-treesitter's python indent query miscounts by one level
                -- for a `try:` nested 3+ blocks deep (class -> def -> try, or
                -- def -> def -> try) - `if`/`for`/etc. at the same depths are
                -- fine, only `try` is affected. This branch is archived
                -- upstream so it won't get fixed; fall back to Neovim's own
                -- bundled Python indentscript instead, which doesn't have it.
                disable = { "python" },
            },
        })
    end,
}
