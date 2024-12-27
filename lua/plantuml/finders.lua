local M = {}

---@class plantuml.Block
---@field content string
---@field start_line integer
---@field end_line integer

--- Find plantuml code blocks
---@return plantuml.Block|nil
---@return string|nil error
function M.find_plantuml_block()
	local filetype = vim.bo.filetype
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local current_line = cursor_pos[1]
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

	local start_line, end_line = 0, 0
	local start_pattern, end_pattern

	if filetype == "markdown" then
		start_pattern = "^```plantuml"
		end_pattern = "^```$"
	elseif filetype == "latex" or filetype == "tex" then
		start_pattern = "\\begin{plantuml}"
		end_pattern = "\\end{plantuml}"
	else
		start_pattern = "@staruml"
		end_pattern = "@enduml"
	end

	for i = current_line, 1, -1 do
		if lines[i]:match(start_pattern) then
			start_line = i
			break
		end
	end

	if start_line == 0 then
		return nil, "No plantuml block found"
	end

	for i = start_line + 1, #lines do
		if lines[i]:match(end_pattern) then
			end_line = i
			break
		end
	end

	if end_line == 0 then
		return nil, "No plantuml block end found"
	end

	local block_content
	if filetype == "markdown" then
		block_content = table.concat(lines, "\n", start_line + 1, end_line - 1)
	else
		block_content = table.concat(lines, "\n", start_line, end_line)
	end

	return {
		content = block_content,
		start_line = start_line,
		end_line = end_line,
	}
end

return M
