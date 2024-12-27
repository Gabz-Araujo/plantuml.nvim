local M = {}

local Job = require("plenary.job")
local config = require("plantuml.config")

--- Sanitize input for shell commands
---@param input string
---@return string
function M.sanitize_input(input)
	return input:gsub('[;&|"]', "")
end

--- Build PlantUML command
---@param input string
---@param output_dir string
---@return string
function M.build_plantuml_command(input, output_dir)
	local sanitized_input = M.sanitize_input(input)
	local sanitized_output = M.sanitize_input(output_dir)
	return string.format(
		"%s -%s -o %s %s",
		config.options.plantuml_path,
		config.options.output_format,
		sanitized_output,
		sanitized_input
	)
end

--- Execute PlantUML command asynchronously
---@param command string
---@param callback function
function M.execute_plantuml_command(command, callback)
	print("Executing command: " .. command)
	Job:new({
		command = "sh",
		args = { "-c", command },
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
