local M = {}

local filetype_patterns = {
	markdown = { start = "^```plantuml", ["end"] = "^```$" },
	latex = { start = "\\begin{plantuml}", ["end"] = "\\end{plantuml}" },
	tex = { start = "\\begin{plantuml}", ["end"] = "\\end{plantuml}" },
}

---@class plantuml.Block
---@field content string
---@field start_line integer
---@field end_line integer

--- Find plantuml code blocks
---@return plantuml.Block|nil
---@return string|nil
function M.find_plantuml_block()
	local filetype = vim.bo.filetype
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local current_line = cursor_pos[1]
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

	local start_line, end_line = nil, nil

	local patterns = filetype_patterns[filetype] or { start = "@startuml", ["end"] = "@enduml" }
	local start_pattern = patterns.start
	local end_pattern = patterns["end"]

	for i = current_line, 1, -1 do
		if lines[i]:match(start_pattern) then
			start_line = i
			break
		end
	end

	if start_line == nil then
		vim.notify("No plantuml block found", vim.log.levels.ERROR)
		return nil
	end

	for i = start_line + 1, #lines do
		if lines[i]:match(end_pattern) then
			end_line = i
			break
		end
	end

	if end_line == nil then
		vim.notify("No plantuml block found", vim.log.levels.ERROR)
		return nil
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
