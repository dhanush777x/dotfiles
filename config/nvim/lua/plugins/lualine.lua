return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
        local cp = require("catppuccin.palettes").get_palette("mocha")

        require("lualine").setup({
            options = {
                theme = {
                    normal = {
                        a = { fg = cp.base, bg = cp.lavender, gui = "bold" },
                        b = { fg = cp.text, bg = cp.surface1 },
                        c = { fg = cp.text, bg = cp.base },
                    },
                    insert = {
                        a = { fg = cp.base, bg = cp.green, gui = "bold" },
                    },
                    visual = {
                        a = { fg = cp.base, bg = cp.mauve, gui = "bold" },
                    },
                    replace = {
                        a = { fg = cp.base, bg = cp.red, gui = "bold" },
                    },
                    inactive = {
                        a = { fg = cp.overlay1, bg = cp.base },
                        b = { fg = cp.overlay1, bg = cp.base },
                        c = { fg = cp.overlay1, bg = cp.base },
                    },
                },
            },
            sections = {
                lualine_c = { { "filename", file_status = true, path = 1 } },
            },
        })
    end,
}
