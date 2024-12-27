local M = {}

---@alias RenderResult
---| { content: string, line_number: integer, is_image: boolean, filetype: string }

---@alias RenderCallBack fun(result: RenderResult|nil)

--- Insert rendered diagram into buffer
---@param result RenderResult
function M.insert_rendered_diagram(result)
	if not result or not result.content then
		vim.notify("Error: No content to insert", vim.log.levels.ERROR)
		return
	end

	local output_lines

	if result.is_image then
		local image_path = result.content
		if result.filetype == "markdown" then
			output_lines = { "![PlantUML Diagram](" .. image_path .. ")" }
		elseif result.filetype == "latex" or result.filetype == "tex" then
			output_lines = {
				"\\begin{figure}[h]",
				"    \\centering",
				"    \\includegraphics[width=\\textwidth]{" .. image_path .. "}",
				"    \\caption{PlantUML Diagram}",
				"    \\label{fig:plantuml_diagram}",
				"\\end{figure}",
			}
		else
			output_lines = { "![PlantUML Diagram](" .. image_path .. ")" }
		end
	else
		local content_lines = vim.split(result.content, "\n")
		if result.filetype == "markdown" then
			output_lines = { "```txt" }
			vim.list_extend(output_lines, content_lines)
			table.insert(output_lines, "```")
		else
			output_lines = content_lines
		end
	end

	vim.schedule(function()
		vim.api.nvim_buf_set_lines(0, result.line_number, result.line_number, false, output_lines)
	end)
end

return M
