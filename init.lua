-- Basic settings
vim.opt.number = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.spelllang = "en_gb"

-- Leader (this is here so plugins etc pick it up)
vim.g.mapleader = "," -- anywhere you see <leader> means hit ,

-- Use system clipboard
vim.opt.clipboard:append({ "unnamed", "unnamedplus" })

-- Display settings
vim.opt.termguicolors = true
vim.o.background = "dark" -- set to "dark" for dark theme

-- Scrolling and UI settings
vim.opt.signcolumn = 'yes'
vim.opt.wrap = false
vim.opt.sidescrolloff = 8
vim.opt.scrolloff = 8

-- Title
vim.opt.title = true
vim.opt.titlestring = "nvim"

-- Persist undo (persists your undo history between sessions)
vim.opt.undodir = vim.fn.stdpath("cache") .. "/undo"
vim.opt.undofile = true

-- Tab stuff
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true

-- Search configuration
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.gdefault = true

-- open new split panes to right and below (as you probably expect)
vim.opt.splitright = true
vim.opt.splitbelow = true

-- LSP
vim.lsp.inlay_hint.enable(true)

vim.opt.tags = "./.tags;$HOME"

local plugins = {
    { "nvim-lua/plenary.nvim" }, -- used by other plugins

    -- Gruvbox theme (feel free to choose another!)
    { "ellisonleao/gruvbox.nvim" },

    { "romainl/vim-cool" },
    { "thesis/vim-solidity" },
    { "jeetsukumaran/vim-filebeagle" },

    -- Telescope command menu
    { "nvim-telescope/telescope.nvim" },
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

    -- TreeSitter
    { "nvim-treesitter/nvim-treesitter",          build = ":TSUpdate" },

    -- LSP stuff
    { 'mason-org/mason.nvim' },           -- installs LSP servers
    { 'neovim/nvim-lspconfig' },          -- configures LSPs
    { 'mason-org/mason-lspconfig.nvim' }, -- links the two above

    -- Some LSPs don't support formatting, this fills the gaps
    { 'stevearc/conform.nvim' },

    { "nvim-treesitter/nvim-treesitter-context" },
    { "tpope/vim-sleuth" },

    -- Autocomplete engine (LSP, snippets etc)
    -- see keymap:
    -- https://cmp.saghen.dev/configuration/keymap.html#default
    {
        'saghen/blink.cmp',
        version = '1.*',
        opts = {
            keymap = {
                preset = 'default',
                ['<C-k>'] = { 'select_prev', 'fallback' },
                ['<C-j>'] = { 'select_next', 'fallback' },
                ['<C-s>'] = { 'show_signature', 'hide_signature' },
                ['<C-y>'] = { 'select_and_accept' },
            },
            appearance = { nerd_font_variant = 'mono' },
            sources = {
                default = { 'lsp', 'path', 'buffer' },
            },
            signature = { enabled = true },
            fuzzy = { implementation = "prefer_rust_with_warning" }
        },
        opts_extend = { "sources.default" }
    },

    { "lewis6991/gitsigns.nvim" },

    {
        'ggandor/leap.nvim',
        config = function()
            require('leap').add_default_mappings()
        end
    },

    -- Debug Adapter Protocol
    { "mfussenegger/nvim-dap" },

    -- Scala LSP support
    {
        "scalameta/nvim-metals",
        ft = { "scala", "sbt", "java" },
        opts = function()
            local metals_config = require("metals").bare_config()

            -- Example of settings
            metals_config.settings = {
                showImplicitArguments = true,
                excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
            }

            -- *READ THIS*
            -- I *highly* recommend setting statusBarProvider to either "off" or "on"
            --
            -- "off" will enable LSP progress notifications by Metals and you'll need
            -- to ensure you have a plugin like fidget.nvim installed to handle them.
            --
            -- "on" will enable the custom Metals status extension and you *have* to have
            -- a have settings to capture this in your statusline or else you'll not see
            -- any messages from metals. There is more info in the help docs about this
            metals_config.init_options.statusBarProvider = "off"

            -- Use default LSP capabilities since we're using blink.cmp
            metals_config.capabilities = vim.lsp.protocol.make_client_capabilities()

            metals_config.on_attach = function(client, bufnr)
                require("metals").setup_dap()

                -- Helper function for keymaps
                local function map(mode, lhs, rhs, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, lhs, rhs, opts)
                end

                -- LSP mappings
                map("n", "gD", vim.lsp.buf.definition)
                map("n", "K", vim.lsp.buf.hover)
                map("n", "gi", vim.lsp.buf.implementation)
                map("n", "gr", vim.lsp.buf.references)
                map("n", "gds", vim.lsp.buf.document_symbol)
                map("n", "gws", vim.lsp.buf.workspace_symbol)
                map("n", "<leader>cl", vim.lsp.codelens.run)
                map("n", "<leader>sh", vim.lsp.buf.signature_help)
                map("n", "<leader>rn", vim.lsp.buf.rename)
                map("n", "<leader>f", vim.lsp.buf.format)
                map("n", "<leader>ca", vim.lsp.buf.code_action)

                map("n", "<leader>ws", function()
                    require("metals").hover_worksheet()
                end)

                -- all workspace diagnostics
                map("n", "<leader>aa", vim.diagnostic.setqflist)

                -- all workspace errors
                map("n", "<leader>ae", function()
                    vim.diagnostic.setqflist({ severity = "E" })
                end)

                -- all workspace warnings
                map("n", "<leader>aw", function()
                    vim.diagnostic.setqflist({ severity = "W" })
                end)

                -- buffer diagnostics only
                map("n", "<leader>d", vim.diagnostic.setloclist)

                map("n", "[c", function()
                    vim.diagnostic.goto_prev({ wrap = false })
                end)

                map("n", "]c", function()
                    vim.diagnostic.goto_next({ wrap = false })
                end)

                -- DAP mappings
                map("n", "<leader>dc", function()
                    require("dap").continue()
                end)

                map("n", "<leader>dr", function()
                    require("dap").repl.toggle()
                end)

                map("n", "<leader>dK", function()
                    require("dap.ui.widgets").hover()
                end)

                map("n", "<leader>dt", function()
                    require("dap").toggle_breakpoint()
                end)

                map("n", "<leader>dso", function()
                    require("dap").step_over()
                end)

                map("n", "<leader>dsi", function()
                    require("dap").step_into()
                end)

                map("n", "<leader>dl", function()
                    require("dap").run_last()
                end)
            end

            return metals_config
        end,
        config = function(self, metals_config)
            local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
            vim.api.nvim_create_autocmd("FileType", {
                pattern = self.ft,
                callback = function()
                    require("metals").initialize_or_attach(metals_config)
                end,
                group = nvim_metals_group,
            })
        end
    }
}

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup(plugins)

vim.cmd.colorscheme("gruvbox") -- activate the theme
require("telescope").setup()   -- command menu

vim.keymap.set({ 'n', 'x', 'o' }, 'S', '<Plug>(leap-backward)')

require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "typescript",
        "python",
        "rust",
        "go",
        "java",
        "scala",
        -- etc!
    },
    sync_install = false,
    auto_install = true,
    highlight = { enable = true, },
})
-- some stuff so code folding uses treesitter instead of older methods
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99

require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "eslint",
        "ruff",
        "rust_analyzer",
        "jdtls",
        -- etc!
    },
    handlers = {
        function(server_name)
            require("lspconfig")[server_name].setup{}
        end,
    },
})

require("conform").setup({
    default_format_opts = { lsp_format = "fallback" },
    formatters_by_ft = {
        typescript = { "prettierd" },
        typescriptreact = { "prettierd" },
        json = { "prettierd" },
        solidity = { "prettierd" },
        go = { "gofmt" },
        java = { "google-java-format" },
        scala = { "scalafmt" },
        -- etc
    },
})

require("treesitter-context").setup({
    enable = true,            -- Enable this plugin (Can be enabled/disabled later via commands)
    multiwindow = false,      -- Enable multiwindow support.
    max_lines = 0,            -- How many lines the window should span. Values <= 0 mean no limit.
    min_window_height = 0,    -- Minimum editor window height to enable context. Values <= 0 mean no limit.
    line_numbers = true,
    multiline_threshold = 20, -- Maximum number of lines to show for a single context
    trim_scope = 'outer',     -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
    mode = 'cursor',          -- Line used to calculate context. Choices: 'cursor', 'topline'
    -- Separator between context and content. Should be a single character string, like '-'.
    -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
    separator = nil,
    zindex = 20,     -- The Z-index of the context window
    on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
})

vim.diagnostic.config({
    virtual_lines = true
})

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function(args)
        require("conform").format({ bufnr = args.buf })
    end,
})

-- keybinds
vim.keymap.set("n", "<leader>fo", require('conform').format)

local tele_builtin = require("telescope.builtin")
vim.keymap.set("n", "<C-p>", function()
    local ok = pcall(tele_builtin.git_files, {})
    if not ok then
        tele_builtin.find_files({})
    end
end, {})
vim.keymap.set("n", "<leader>fa", tele_builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", tele_builtin.live_grep, {})
vim.keymap.set("n", "<C-b>", tele_builtin.buffers, {})
vim.keymap.set("n", "<leader>fh", tele_builtin.help_tags, {})
vim.keymap.set("n", "<Tab>", ":b#<CR>", { noremap = true, silent = true, desc = "Switch to last used buffer" })
vim.keymap.set("n", "<C-j>", "<C-W><C-J>")
vim.keymap.set("n", "<C-k>", "<C-W><C-K>")
vim.keymap.set("n", "<C-l>", "<C-W><C-L>")
vim.keymap.set("n", "<C-H>", "<C-W><C-H>")
