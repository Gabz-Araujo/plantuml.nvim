local M = {}

local Job = require("plenary.job")
local config = require("plantuml.config")

--- Sanitize input for shell commands
---@param input string
---@return string
function M.sanitize_input(input)
	return input:gsub('[;&|"]', "")
end

---@alias command_table { command: string, args: string[]}

--- Build PlantUML command
---@param input string
---@param output_dir string
---@return command_table
function M.build_plantuml_command(input, output_dir)
	local sanitized_input = M.sanitize_input(input)
	local sanitized_output_dir = M.sanitize_input(output_dir)
	return {
		command = config.options.plantuml_path,
		args = {
			"-" .. config.options.output_format,
			"-o",
			sanitized_output_dir,
			sanitized_input,
		},
	}
end

---@return string
function M.get_output_extension()
	return config.options.format_extension_map[config.options.output_format] or config.options.output_format
end

--- Execute PlantUML command asynchronously
---@param command_table command_table
---@param callback function
function M.execute_plantuml_command(command_table, callback)
	Job:new({
		command = command_table.command,
		args = command_table.args,
		on_exit = function(j, return_val)
			callback(return_val == 0, j:result())
		end,
	}):start()
end

---@return string|nil
function M.get_current_directory()
	local handle = io.popen(vim.fn.has("win32") == 1 and "cd" or "pwd")
	if not handle then
		return nil
	end
	local result = handle:read("*a")
	handle:close()
	return result:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
end

return M
