vim.api.nvim_command('LuaReload satiable2.dynamic_access_table')
vim.api.nvim_command('LuaReload satiable2.utils')

local lu = require'luaunit'

local len = require'satiable2.utils'.len

local satiable = require'satiable2'

local function module_cleanup(module)
    package.loaded[module] = nil
    return require(module)
end

TestStatusline = {}
function TestStatusline:setUp()
    local satiable = module_cleanup('satiable2')
    self.statusline = satiable.statusline
end

function TestStatusline:test_statusline_is_a_table()
    lu.assert_is_table(self.statusline, 'statusline should be a table')
end

function TestStatusline:test_statusline_is_callable()
    lu.assert_true(pcall(self.statusline), 'statusline should be callable')
end

TestStatuslineStructure = {}
function TestStatuslineStructure:setUp()
    local satiable = module_cleanup('satiable2')
    self.satiable = satiable
    self.statusline = satiable.statusline
end

function TestStatuslineStructure:test_statusline_contains_items_table()
    lu.assert_eval_to_true(self.statusline.items, 'statusline should contain items')
    lu.assert_is_table(self.statusline.items, 'statusline.items should be a table')
end

function TestStatuslineStructure:test_statusline_contains_tables_indexed_with_numbers()
    self.statusline[1] = {}
    lu.assert_error_msg_contains('statusline configuration must be a table', function() self.statusline[1] = 1 end,
        'statusline should not accept values other than tables for number-indexes')
    self.satiable.statusline = {
        { 'a' },
        { 'b' },
    }
    lu.assert_equals(len(self.statusline), 2, 'assigning multiple tables to statusline should overwrite previous configuration')
end

TestItems = {}
function TestItems:setUp()
    local satiable = module_cleanup('satiable2')
    self.satiable = satiable
    self.items = satiable.statusline.items
end

function TestItems:test_items_functions_can_call_items_defined_earlier()
    local called = {}
    self.items.a = function()
        called.a = true
        return 'a'
    end
    self.items.b = function()
        called.b = true
        return self.items.a() .. 'b'
    end
    local result = self.satiable.statusline.items.b()
    lu.assert_equals(result, 'ab', 'functions in items should refer to earlier items functions')
    lu.assert_true(called.b, 'function in items should be called')
    lu.assert_true(called.a, 'dependent function in items should be called')
end

function TestItems:test_assigning_to_items_table_overwrites_items()
    self.items.a = function()
        return 'a'
    end
    local statusline = self.satiable.statusline
    -- cannot assign to items directly as this would overwrite local variable
    statusline.items = {
        b = function()
            return 'b'
        end
    }
    lu.assert_nil(self.satiable.statusline.items.a)
    lu.assert_not_nil(self.satiable.statusline.items.b)
end

function TestItems:test_define_multiple_functions_together()
    local called = {}
    local statusline = self.satiable.statusline
    local items = self.items  -- can refer to items like this (as long as `items` is not re-assigned
    statusline.items = {
        a = function()
            called.a = true
            return 'a'
        end,
        b = function()
            called.b = true
            return items.a() .. 'b'
        end
    }
    local result = self.satiable.statusline.items.b()
    lu.assert_equals(result, 'ab', 'functions in items should refer to earlier items functions')
    lu.assert_true(called.b, 'function in items should be called')
    lu.assert_true(called.a, 'dependent function in items should be called')
    items.c = function()
        called.c = true
        return items.a() .. 'c'
    end
    called = {}
    result = self.satiable.statusline.items.c()
    lu.assert_equals(result, 'ac', 'functions in items should refer to earlier items functions')
    lu.assert_true(called.c, 'function in items should be called')
    lu.assert_true(called.a, 'dependent function in items should be called')
end

lu.LuaUnit.run()

-- cleanup after running tests
TestStatusline = nil
TestStatuslineStructure = nil
TestItems = nil
package.loaded.luaunit = nil
