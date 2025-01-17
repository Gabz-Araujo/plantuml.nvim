local M = {}

local Job = require("plenary.job")
local config = require("plantuml.config")

---@alias command_table { command: string, args: string[]}

--- Build PlantUML command
---@param input string
---@param output_dir string
---@return command_table
function M.build_plantuml_command(input, output_dir)
	return {
		command = config.options.plantuml_path,
		args = {
			"-" .. config.options.output_format,
			"-o",
			output_dir,
			input,
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
	local ok, result = pcall(function()
		local handle = io.popen(vim.fn.has("win32") == 1 and "cd" or "pwd")
		if not handle then
			return nil
		end
		local res = handle:read("*a")
		handle:close()
		return res:gsub("^%s*(.-)%s*$", "%1")
	end)
	if not ok then
		return nil
	end
	return result
end

local output_bufnr = nil
local api = vim.api

function M.update_or_create_buffer(result)
	vim.schedule(function()
		if output_bufnr and api.nvim_buf_is_valid(output_bufnr) then
			local lines = vim.split(result.content, "\n")
			api.nvim_buf_set_lines(output_bufnr, 0, -1, false, lines)
		else
			output_bufnr = api.nvim_create_buf(false, true)
			vim.bo[output_bufnr].buftype = "nofile"
			vim.bo[output_bufnr].bufhidden = "wipe"
			vim.bo[output_bufnr].swapfile = false
			api.nvim_buf_set_name(output_bufnr, "PlantUML Output")

			local lines = vim.split(result.content, "\n")
			api.nvim_buf_set_lines(output_bufnr, 0, -1, false, lines)
			vim.bo[output_bufnr].filetype = "plantuml"

			vim.cmd("vsplit")
			api.nvim_win_set_buf(0, output_bufnr)
		end
	end)
end

function M.clear_output_buffer()
	if output_bufnr and api.nvim_buf_is_valid(output_bufnr) then
		api.nvim_buf_delete(output_bufnr, { force = true })
	end
	output_bufnr = nil
end

-- Loading utils

local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local spinner_index = 1
local loading_notification = nil
local timer = nil

local function update_spinner()
	if loading_notification then
		spinner_index = (spinner_index % #spinner_frames) + 1
		loading_notification =
			vim.notify("Rendering PlantUML diagram... " .. spinner_frames[spinner_index], vim.log.levels.INFO, {
				id = "plantuml_loading",
				hide_from_history = true,
			})
	else
		if timer then
			timer:stop()
		end
	end
end

function M.start_loading_indicator()
	if loading_notification then
		return
	end
	spinner_index = 1
	loading_notification =
		vim.notify("Rendering PlantUML diagram... " .. spinner_frames[spinner_index], vim.log.levels.INFO, {
			id = "plantuml_loading",
			hide_from_history = true,
		})
	timer = vim.loop.new_timer()
	timer:start(
		0,
		100,
		vim.schedule_wrap(function()
			update_spinner()
		end)
	)
end

function M.stop_loading_indicator()
	if timer then
		timer:stop()
		timer:close()
		timer = nil
	end

	if loading_notification then
		vim.notify("PlantUML diagram rendered", vim.log.levels.INFO, {
			id = "plantuml_loading",
		})
		loading_notification = nil
	end
end

return M
