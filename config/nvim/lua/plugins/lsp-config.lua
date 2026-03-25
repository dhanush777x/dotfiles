return {
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        config = function()
            require("mason").setup()
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            ensure_installed = { "bashls", "lua_ls", "cssls", "pylsp" },
            auto_install = true,
        },
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local capabilities = require("blink.cmp").get_lsp_capabilities()

            -- Define configs
            vim.lsp.config("bashls", { capabilities = capabilities })
            vim.lsp.config("cssls", { capabilities = capabilities })
            vim.lsp.config("lua_ls", { capabilities = capabilities })
            vim.lsp.config("pylsp", { capabilities = capabilities })

            -- Enable configs
            vim.lsp.enable("bashls")
            vim.lsp.enable("cssls")
            vim.lsp.enable("lua_ls")
            vim.lsp.enable("pylsp")

            -- Keymaps
            vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
            vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, { desc = "Declaration" })
            vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Definitions" })
            vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, { desc = "References" })
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
        end,
    },
}
