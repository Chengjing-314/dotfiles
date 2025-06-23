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
    use 'nvim-treesitter/nvim-treesitter'
    use { "catppuccin/nvim", as = "catppuccin" }

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

require('catppuccin').setup({
    flavour = "macchiato" -- latte, frappe, macchiato, mocha
})

vim.cmd('colorscheme catppuccin')

require'nvim-treesitter.configs'.setup {
    -- A list of parser names, or "all" (the listed parsers MUST always be installed)
    ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" , "python" },
  
    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,
  
    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
    auto_install = true,
  
    -- List of parsers to ignore installing (or "all")
    ignore_install = { "javascript" },
  
    ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
    -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!
  
    highlight = {
      enable = true,
  
      -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
      -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
      -- the name of the parser)
      -- list of language that will be disabled
      disable = { "c", "rust" },
      -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
      disable = function(lang, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
              return true
          end
      end,
  
      -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
      -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
      -- Using this option may slow down your editor, and you may see some duplicate highlights.
      -- Instead of true it can also be a list of languages
      additional_vim_regex_highlighting = false,
    },
  }

-- Custom function: Duplicate and comment
local function duplicate_and_comment()
    local line = vim.api.nvim_get_current_line()   -- Get the current line
    local cursor_pos = vim.api.nvim_win_get_cursor(0) -- Get the current cursor position

    vim.api.nvim_buf_set_lines(0, cursor_pos[1], cursor_pos[1], false, { line }) -- Insert the line below
    require('Comment.api').toggle.linewise.current() -- Comment the duplicated line

    -- Move the cursor down by one line
    vim.api.nvim_win_set_cursor(0, { cursor_pos[1] + 1, cursor_pos[2] })
end

-- Keymaps
vim.keymap.set('n', '<leader>w', ':w<CR>', { noremap = true, silent = true }) -- Save file
vim.keymap.set('n', '<leader>d', 'yyp', { noremap = true, silent = true })    -- Duplicate line
vim.keymap.set('n', '<leader>c', require('Comment.api').toggle.linewise.current, { noremap = true, silent = true }) -- Toggle comment
vim.keymap.set('n', '<leader>D', duplicate_and_comment, { noremap = true, silent = true }) -- Duplicate and comment

if vim.g.vscode then
    -- Folding keymaps using VSCode commands
    vim.keymap.set('n', 'zM', function() vim.fn.VSCodeNotify('editor.foldAll') end, { silent = true })
    vim.keymap.set('n', 'zR', function() vim.fn.VSCodeNotify('editor.unfoldAll') end, { silent = true })
    vim.keymap.set('n', 'zc', function() vim.fn.VSCodeNotify('editor.fold') end, { silent = true })
    vim.keymap.set('n', 'zC', function() vim.fn.VSCodeNotify('editor.foldRecursively') end, { silent = true })
    vim.keymap.set('n', 'zo', function() vim.fn.VSCodeNotify('editor.unfold') end, { silent = true })
    vim.keymap.set('n', 'zO', function() vim.fn.VSCodeNotify('editor.unfoldRecursively') end, { silent = true })
    vim.keymap.set('n', 'za', function() vim.fn.VSCodeNotify('editor.toggleFold') end, { silent = true })

    -- Custom cursor movement: Avoid opening folds with 'j' and 'k'
    local function move_cursor_no_fold(direction)
        vim.fn.VSCodeNotify('cursorMove', { to = direction, by = 'wrappedLine', value = 1 })
        return ''
    end

    vim.keymap.set('n', 'j', function() return move_cursor_no_fold('down') end, { expr = true, silent = true })
    vim.keymap.set('n', 'k', function() return move_cursor_no_fold('up') end, { expr = true, silent = true })
end


