# What is satiable

SaTiaBLe is a Lua configuration for Neovim that sets STatusLine and TaBLine.

# Configuration

```lua
-- define context
require'satiable'.context = { -- optional lazily loaded commonly accessed properties
    -- all code in satiable has access to this
    bufname = {
        full = function() return vim.fn.fnamemodify(vim.fn.bufname(), ':p') end,
        -- ...
    },
    -- ...
}
-- define parts common for statusline and tabline
require'satiable'.parts = {
    sep = ' ', -- can also be a function with access to context
    -- ...
}
-- TODO: default parts and context
require'satiable'.statusline = {
    {
        condition = 'context.filetype == "help"' -- or function
        -- condition for which whole statusline should be displayed
        -- first statusline (in order of declaration) for which condition is true will be displayed
        -- condition key is optional, meaning true - makes sense only for last statusline configuration
        -- can be used to check if current window is active ('context.active'):w

        highlight = { -- or single string, when not set/group is not defined, 'Statusline' is used
            {
                condition = 'context.mode == "insert"', -- can define condition as well
                'StlInsertMode', -- first defined is used when condition is met
                'Normal'
            },
            'StlHelp',
            'Statusline' -- first that is defined is used
        }, -- optional highlight group for this configuration when part doesn't define own highlight
        {
            condition = function() -- display part conditionally
                return not string.match(context.bufname.full, '^term://')
            end
            highlight = { -- optional highlight for part
                condition = 'true' -- can also have condition
                'Directory'
            }
            function() -- can also be an expression written as string
                return vim.fn.getcwd()
            end,
            -- multiple parts can be defined (sharing condition and highlighting)
        },
        'parts.sep' -- parts can also be a string (or function) when no condition or highlight are needed
        -- parts are added in order of definition (by numeric key)
    },
    -- ...
}
-- TODO: tabline configuration
```

```vim
set statusline=%!luaeval('require\''satiable\''.statusline()')
set tabline=%!luaeval('require\''satiable\''.tabline()')
```

# Roadmap

- [ ] configure in Vimscript (init.vim)
