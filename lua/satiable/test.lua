local function clean_reload()
    package.loaded.satiable = nil
    package.loaded.luaunit = nil
    for key in pairs(_G) do
        if string.match(key, '^Test') then
            _G[key] = nil
        end
    end
end
clean_reload()

local lu = require'luaunit'


TestStatusline = {}

function TestStatusline:setUp()
    local satiable = require'satiable'
    self.statusline = satiable.statusline
end

function TestStatusline:tearDown()
    package.loaded.satiable = nil
end

function TestStatusline:test_statusline_is_callable()
    lu.assert_true(pcall(self.statusline),
        'statusline should be callable')
end

function TestStatusline:test_statusline_call_without_args_returns_string()
    local result = self.statusline()
    lu.assert_is_string(result,
        'statusline call without arguments should return string')
end

function TestStatusline:test_statusline_call_with_table_arg_returns_nil()
    local result = self.statusline{}
    lu.assert_is_nil(result,
        'statusline call with single table argument should return nil')
end

function TestStatusline:test_indexing_empty_statusline_should_return_default_configuration()
    lu.assert_not_nil(self.statusline[1],
        'statusline should return default configuration table when not set by user')
end

function TestStatusline:test_statusline_no_args_call_returns_rendered_statusline()
    lu.assert_equals(self.statusline(), '%<%f %h%m%r%=%-14.(%l,%c%V%) %P',
        'statusline no args call should return rendered statusline')
end

function TestStatusline:test_statusline_single_table_arg_call_configures_statuslines()
    self.statusline{
        {
        }
    }
    lu.assert_equals(self.statusline(), '',
        'statusline table arg call should configure user-defined statuslines')
end

function TestStatusline:test_statusline_configurations_can_be_added_one_by_one()
    table.insert(self.statusline, {'a'})
    lu.assert_equals(self.statusline(), 'a',
        'statusline configurations should be able to be added one by one')
end

function TestStatusline:test_statusline_renders_subtables_with_multiple_items_as_groups()
    self.statusline{
        {
            {
                'a',
                'b',
            },
            'c'
        }
    }
    lu.assert_equals(self.statusline(), '%(ab%)c',
        'statusline should render subtables with multiple items as groups')
end

function TestStatusline:test_statusline_renders_subtables_with_single_item_as_item()
    self.statusline{
        {
            {
                'a'
            }
        }
    }
    lu.assert_equals(self.statusline(), 'a',
        '')
end

TestItems = {}

function TestItems:setUp()
    local satiable = require'satiable'
    self.items = satiable.items
end

function TestItems:tearDown()
    package.loaded.satiable = nil
end

function TestItems:test_items_is_callable()
    lu.assert_true(pcall(self.items),
        'items should be callable')
end

function TestItems:test_items_call_with_table_arg_returns_nil()
    local result = self.items{}
    lu.assert_is_nil(result,
        'items call with single table argument should return nil')
end

function TestItems:test_indexing_empty_items_should_return_default_item()
    lu.assert_not_nil(self.items.vim_file_path,
        'empty items table should return default items')
end

function TestItems:test_items_single_table_arg_call_configures_items_table()
    self.items{
        a = function()
            return 'a'
        end,
        b = 'b',
    }
    lu.assert_not_nil(self.items.a,
        'items should be configured by single table arg call')
    lu.assert_not_nil(self.items.b,
        'items should be configured by single table arg call')
end

function TestItems:test_items_can_add_new_items_one_by_one()
    self.items.a = 'a'
    lu.assert_not_nil(self.items.a,
        'items should be able to add new items one by one')
end

function TestItems:test_items_can_reference_to_other_items()
    self.items{
        b = function()
            return self.items.a() .. 'b'
        end,
        a = function()
            return 'a'
        end,
    }
    lu.assert_equals(self.items.b(), 'ab',
        'items should be able to reference other items')
end

TestStatuslineItems = {}

function TestStatuslineItems:setUp()
    local satiable = require'satiable'
    self.items = satiable.items
    self.statusline = satiable.statusline
end

function TestStatuslineItems:tearDown()
    package.loaded.satiable = nil
end

function TestStatuslineItems:test_statusline_can_use_default_items()
    self.statusline{
        { self.items.vim_file_path }
    }
    lu.assert_equals(self.statusline(), '%f',
        'statusline should be able to refer to default items')
end

function TestStatuslineItems:test_statusline_can_use_added_items()
    self.items{
        a = function()
            return 'a'
        end
    }
    self.statusline{
        { self.items.a }
    }
    lu.assert_equals(self.statusline(), [[%{luaeval("require'satiable'.items.a()")}]],
        'statusline should be able to refer to added items')
end

function TestStatuslineItems:test_statusline_renders_functions_as_expressions()
    self.items{
        a = function()
            return 1
        end
    }
    self.statusline{
        {
            self.items.a
        }
    }
    lu.assert_equals(self.statusline(), [[%{luaeval("require'satiable'.items.a()")}]],
        'items that are functions are rendered as expressions')
end


lu.LuaUnit.run()

clean_reload()
