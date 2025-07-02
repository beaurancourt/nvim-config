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
        -- etc!
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
vim.keymap.set("n", "<C-p>", tele_builtin.git_files, {})
vim.keymap.set("n", "<leader>fa", tele_builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", tele_builtin.live_grep, {})
vim.keymap.set("n", "<C-b>", tele_builtin.buffers, {})
vim.keymap.set("n", "<leader>fh", tele_builtin.help_tags, {})
vim.keymap.set("n", "<Tab>", ":b#<CR>", { noremap = true, silent = true, desc = "Switch to last used buffer" })
vim.keymap.set("n", "<C-j>", "<C-W><C-J>")
vim.keymap.set("n", "<C-k>", "<C-W><C-K>")
vim.keymap.set("n", "<C-l>", "<C-W><C-L>")
vim.keymap.set("n", "<C-H>", "<C-W><C-H>")
