local M = {}

local utils = require("plantuml.utils")
local Path = require("plenary.path")
local config = require("plantuml.config")
local finders = require("plantuml.finders")

--- Render PlantUML diagram
--- @param format string|nil Output format (optional)
--- @param callback function Callback function with render result
function M.render_plantuml(format, callback)
	local ft = vim.bo.filetype
	local block, err = finders.find_plantuml_block()
	if not block then
		vim.notify("Error: " .. (err or "Unknown error"), vim.log.levels.ERROR)
		return
	end

	local output_format = format or config.options.output_format
	local output_extension = config.options.format_extension_map[output_format] or output_format

	local temp_input = Path:new(config.options.temp_dir, "input.puml")
	local temp_output = Path:new(config.options.temp_dir, "input." .. output_extension)

	if not temp_input:parent():exists() then
		temp_input:parent():mkdir({ parents = true })
	end

	temp_input:write(block.content, "w")
	local previous_format = config.options.output_format
	config.options.output_format = output_format

	local command_table = utils.build_plantuml_command(temp_input:absolute(), config.options.temp_dir)

	utils.execute_plantuml_command(command_table, function(success, result)
		config.options.output_format = previous_format

		if not success then
			vim.notify("Error: PlantUML rendering failed\n" .. table.concat(result, "\n"), vim.log.levels.ERROR)
			if callback then
				callback(nil)
			end
			return
		end

		local is_image = vim.tbl_contains({ "png", "svg", "eps", "pdf" }, output_extension)
		local final_output_path

		if is_image then
			local timestamp = os.time()
			local random_suffix = math.random(1000, 9999)
			local filename = string.format("plantuml_diagram_%d_%d.%s", timestamp, random_suffix, output_extension)
			local output_dir = config.options.image_output_dir or utils.get_current_directory()
			output_dir = Path:new(output_dir)
			output_dir:mkdir({ parents = true, exists_ok = true })
			final_output_path = Path:new(output_dir, filename)

			local ok, error = os.rename(temp_output:absolute(), final_output_path:absolute())
			if not ok then
				vim.notify("Error moving output file: " .. error, vim.log.levels.ERROR)
				if callback then
					callback(nil)
				end
				return
			end
		else
			final_output_path = temp_output
		end

		local content
		if is_image then
			content = final_output_path:absolute()
		else
			content = final_output_path:read()
			temp_output:rm()
		end
		temp_input:rm()

		local render_result = {
			content = content,
			line_number = block.end_line,
			is_image = is_image,
			filetype = ft,
		}

		if callback then
			callback(render_result)
		end
	end)
end

return M
