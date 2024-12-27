local M = {}
--- Insert rendered diagram into buffer
---@param result RenderResult
function M.insert_rendered_diagram(result)
	if not result or not result.content then
		vim.notify("Error: No content to insert", vim.log.levels.ERROR)
		return
	end

	local output_lines

	if result.is_image then
		if result.filetype == "markdown" then
			output_lines = { "![PlantUML Diagram](" .. result.content .. ")" }
		elseif result.filetype == "latex" or result.filetype == "tex" then
			output_lines = {
				"\\begin{figure}[h]",
				"    \\centering",
				"    \\includegraphics[width=\\textwidth]{" .. result.content .. "}",
				"    \\caption{PlantUML Diagram}",
				"    \\label{fig:plantuml_diagram}",
				"\\end{figure}",
			}
		else
			output_lines = { "PlantUML DIagram: " .. result.content }
		end
	else
		if result.filetype == "markdown" then
			output_lines = { "```txt" }
			for line in result.content:gmatch("[^\r\n]+") do
				table.insert(output_lines, line)
			end
			table.insert(output_lines, "```")
		end
	end

	vim.schedule(function()
		vim.api.nvim_buf_set_lines(0, result.line_number, result.line_number, false, output_lines)
	end)
end

return M
