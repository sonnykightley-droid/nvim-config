return {
    'brenoprata10/nvim-highlight-colors',
    event = "BufReadPre",
    opts = {
        render = "foreground",
        enable_hex = true,
        enable_short_hex = true,
        enable_rgb = true,
        enable_hsl = true,
        enable_css_variables = true,
        enable_tailwind = true,
    }
}
