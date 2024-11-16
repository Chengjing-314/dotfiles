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


-- Packer setup
require('packer').startup(function(use)
    -- Plugin Manager
    use 'wbthomason/packer.nvim'

    -- Comment.nvim
    use {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup({
                -- Customize the comment string
                pre_hook = function(ctx)
                    -- Only adjust comment strings for Python files
                    if vim.bo.filetype == 'python' then
                        local U = require('Comment.utils')
            
                        -- Determine whether to use linewise or blockwise commentstring
                        local type = ctx.ctype == U.ctype.line and '__default' or '__multiline'
            
                        -- Define the comment strings
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

local function duplicate_and_comment()
    local line = vim.api.nvim_get_current_line()   -- Get the current line
    local cursor_pos = vim.api.nvim_win_get_cursor(0) -- Get the current cursor position

    vim.api.nvim_buf_set_lines(0, cursor_pos[1], cursor_pos[1], false, { line }) -- Insert the line below
    require('Comment.api').toggle.linewise.current() -- Comment the duplicated line

    -- Move the cursor down by one line
    vim.api.nvim_win_set_cursor(0, { cursor_pos[1] + 1, cursor_pos[2] })
end

-- Keymaps
vim.keymap.set('n', '<leader>w', ':w<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>d', 'yyp', { noremap = true, silent = true })  -- Duplicate line
vim.keymap.set('n', '<leader>c', require('Comment.api').toggle.linewise.current, { noremap = true, silent = true })

-- Map <leader>D to the duplicate and comment function
vim.keymap.set('n', '<leader>D', duplicate_and_comment, { noremap = true, silent = true })

