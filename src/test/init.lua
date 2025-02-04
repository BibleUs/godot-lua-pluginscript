-- @file test/init.lua  Unit test runner
-- This file is part of Godot Lua PluginScript: https://github.com/gilzoide/godot-lua-pluginscript
--
-- Copyright (C) 2021 Gil Barbosa Reis.
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the “Software”), to
-- deal in the Software without restriction, including without limitation the
-- rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
-- sell copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.
local TestRunner = {
	extends = 'SceneTree',
}

function TestRunner:_init()
	local current_script_path = self:get_script().resource_path
	local current_script_filename = current_script_path:get_file()
	local current_script_base_dir = current_script_path:get_base_dir()

	local dir, all_passed = Directory:new(), true
	assert(dir:open(current_script_base_dir) == GD.OK)
	dir:list_dir_begin(true)
	repeat
		local filename = dir:get_next()
		if filename ~= '' and filename ~= current_script_filename then
			local script = GD.load(current_script_base_dir:plus_file(filename))
			local instance = script:new()
			local lua_instance = GD.get_lua_instance(instance)
			local success = xpcall(lua_instance.unittest, GD.print_error, lua_instance)
			print(string.format('%s %s: %s', success and '✓' or '🗴', filename, success and 'passed' or 'failed'))
			all_passed = all_passed and success
		end
	until filename == ''
	dir:list_dir_end()

	self:quit(all_passed and 0 or 1)
end

return TestRunner
