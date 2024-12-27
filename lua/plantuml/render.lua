local M = {}

local utils = require("plantuml.utils")
local Path = require("plenary.path")
local config = require("plantuml.config")
local finders = require("plantuml.finders")

---@alias RenderResult
---| { content: string, line_number: integer, is_image: boolean, filetype: string }

---@alias RenderCallBack fun(result: RenderResult|nil)

--- Render PlantUML diagram
---@param callback RenderCallBack
function M.render_plantuml(callback)
	local ft = vim.bo.filetype
	local block, err = finders.find_plantuml_block()
	if not block then
		vim.notify("Error: " .. (err or "Unknown error"), vim.log.levels.ERROR)
		return
	end

	local temp_input = Path:new(config.options.temp_dir, "input.puml")
	local temp_output = Path:new(config.options.temp_dir, "input." .. config.options.output_format)

	temp_input:write(block.content, "w")

	local command = utils.build_plantuml_command(temp_input:absolute(), config.options.temp_dir)

	utils.execute_plantuml_command(command, function(success, result)
		if not success then
			vim.notify("Error: PlantUML rendering failed\n" .. table.concat(result, "\n"), vim.log.levels.ERROR)
			callback(nil)
			return
		end

		local is_image = vim.tbl_contains({ "png", "svg", "eps", "pdf" }, config.options.output_format)
		local final_output_path

		if is_image then
			local timestamp = os.time()
			local random_suffix = math.random(1000, 9999)
			local filename =
				string.format("plantuml_diagram_%d_%d.%s", timestamp, random_suffix, config.options.output_format)

			local output_dir = config.image_output_dir or utils.get_current_directory()
			output_dir = Path:new(output_dir)

			output_dir:mkdir({ parents = true, exists_ok = true })

			final_output_path = Path:new(output_dir, filename)

			temp_output:rename({ new_name = final_output_path:absolute() })
		else
			final_output_path = temp_output
		end

		local render_result = {
			content = is_image and final_output_path:absolute() or final_output_path:read(),
			line_number = block.end_line,
			is_image = is_image,
			filetype = ft,
		}

		if not is_image then
			temp_input:rm()
			temp_output:rm()
		end

		callback(render_result)
	end)
end

return M
