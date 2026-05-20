-- Leader Key
vim.g.mapleader = " "

-- Basic Settings
vim.opt.number = true            -- Enable line numbers
vim.opt.relativenumber = true    -- Relative line numbers
vim.opt.tabstop = 4              -- 4 spaces for tabs
vim.opt.shiftwidth = 4           -- 4 spaces for indent width
vim.opt.expandtab = true         -- Use spaces instead of tabs
vim.opt.smartindent = true       -- Smart indentation
vim.opt.wrap = false             -- Disable line wrapping
vim.opt.clipboard = "unnamedplus" -- System clipboard access
vim.opt.mouse = "a"              -- Enable mouse support
vim.opt.ignorecase = true        -- Case-insensitive search
vim.opt.smartcase = true         -- Smart case search
vim.opt.syntax = "on"            -- Syntax highlighting

-- Packer setup
require('packer').startup(function(use)
    -- Plugin Manager
    use 'wbthomason/packer.nvim'
    use {
        'nvim-treesitter/nvim-treesitter',
        run = function()
            require('nvim-treesitter').update()
        end,
    }
    use { "catppuccin/nvim", as = "catppuccin" }

    -- Comment.nvim
    use {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup({
                pre_hook = function(ctx)
                    if vim.bo.filetype == 'python' then
                        local U = require('Comment.utils')
                        local type = ctx.ctype == U.ctype.line and '__default' or '__multiline'
                        require('Comment.ft').set('python', {
                            __default = '# %s',
                            __multiline = '# %s',
                        })
                        return require('Comment.ft').get('python')[type]
                    end
                end,
            })
        end
    }
end)

require('catppuccin').setup({
    flavour = "frappe" -- dark, muted work theme
})

vim.cmd('colorscheme catppuccin')

-- nvim-treesitter (main branch, v1.0+) — no more setup{}; install parsers
-- and enable highlighting via FileType autocmd.
local ok_ts, nts = pcall(require, 'nvim-treesitter')
if ok_ts then
    nts.install({
        "c", "lua", "vim", "vimdoc", "query",
        "markdown", "markdown_inline", "python",
    })
end

vim.api.nvim_create_autocmd('FileType', {
    callback = function(args)
        local buf = args.buf
        local ft = vim.bo[buf].filetype
        if ft == 'javascript' then return end -- previously in ignore_install

        -- Skip very large files (previously highlight.disable)
        local max_filesize = 100 * 1024 -- 100 KB
        local fname = vim.api.nvim_buf_get_name(buf)
        local stat_ok, stats = pcall(vim.loop.fs_stat, fname)
        if stat_ok and stats and stats.size > max_filesize then
            return
        end

        local lang = vim.treesitter.language.get_lang(ft) or ft
        if pcall(vim.treesitter.start, buf, lang) then
            vim.bo[buf].syntax = 'off' -- disable additional vim regex highlighting
        end
    end,
})

-- Custom function: Duplicate and comment
local function duplicate_and_comment()
    local line = vim.api.nvim_get_current_line()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_buf_set_lines(0, cursor_pos[1], cursor_pos[1], false, { line })
    require('Comment.api').toggle.linewise.current()
    vim.api.nvim_win_set_cursor(0, { cursor_pos[1] + 1, cursor_pos[2] })
end

vim.opt.iskeyword:remove("_")

-- Keymaps
vim.keymap.set('n', '<leader>w', ':w<CR>', { noremap = true, silent = true }) -- Save file
vim.keymap.set('n', '<leader>d', 'yyp', { noremap = true, silent = true })    -- Duplicate line
vim.keymap.set('n', '<leader>c', require('Comment.api').toggle.linewise.current, { noremap = true, silent = true }) -- Toggle comment
vim.keymap.set('n', '<leader>D', duplicate_and_comment, { noremap = true, silent = true }) -- Duplicate and comment

if vim.g.vscode then
    vim.keymap.set('n', 'zM', function() vim.fn.VSCodeNotify('editor.foldAll') end, { silent = true })
    vim.keymap.set('n', 'zR', function() vim.fn.VSCodeNotify('editor.unfoldAll') end, { silent = true })
    vim.keymap.set('n', 'zc', function() vim.fn.VSCodeNotify('editor.fold') end, { silent = true })
    vim.keymap.set('n', 'zC', function() vim.fn.VSCodeNotify('editor.foldRecursively') end, { silent = true })
    vim.keymap.set('n', 'zo', function() vim.fn.VSCodeNotify('editor.unfold') end, { silent = true })
    vim.keymap.set('n', 'zO', function() vim.fn.VSCodeNotify('editor.unfoldRecursively') end, { silent = true })
    vim.keymap.set('n', 'za', function() vim.fn.VSCodeNotify('editor.toggleFold') end, { silent = true })

    local function move_cursor_no_fold(direction)
        vim.fn.VSCodeNotify('cursorMove', { to = direction, by = 'wrappedLine', value = 1 })
        return ''
    end

    vim.keymap.set('n', 'j', function() return move_cursor_no_fold('down') end, { expr = true, silent = true })
    vim.keymap.set('n', 'k', function() return move_cursor_no_fold('up') end, { expr = true, silent = true })
end
