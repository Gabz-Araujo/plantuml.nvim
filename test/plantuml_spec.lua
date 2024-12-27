local assert = require("luassert")
local plantuml = require("plantuml")
local utils = require("plantuml.utils")
local finders = require("plantuml.finders")
local render = require("plantuml.render")

local function deep_compare(t1, t2)
	if type(t1) ~= "table" or type(t2) ~= "table" then
		return t1 == t2
	end

	for k, v in pairs(t1) do
		if not deep_compare(v, t2[k]) then
			return false
		end
	end

	for k, _ in pairs(t2) do
		if t1[k] == nil then
			return false
		end
	end

	return true
end

describe("plantuml", function()
	before_each(function()
		local lines = {
			"# Test Markdown",
			"",
			"```plantuml",
			"@startuml",
			"A -> B: Hello",
			"B -> A: Hi there",
			"@enduml",
			"```",
			"",
			"Some more text",
		}
		vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)

		plantuml.setup()
	end)

	after_each(function()
		vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
	end)

	it("should find PlantUML block", function()
		vim.api.nvim_win_set_cursor(0, { 4, 0 })
		local fence, err = finders.find_plantuml_block()
		assert.is_nil(err)
		assert.are.same({
			content = "@startuml\nA -> B: Hello\nB -> A: Hi there\n@enduml",
			start_line = 4,
			end_line = 7,
		}, fence)
	end)

	it("should build correct PlantUML command", function()
		local expected_command = {
			command = "plantuml",
			args = { "-png", "-o", "/tmp/output", "/tmp/input.puml" },
		}

		local actual_command = utils.build_plantuml_command("/tmp/input.puml", "/tmp/output")

		assert(deep_compare(expected_command, actual_command), "Generated command table should match expected")
	end)

	it("should render PlantUML diagram", function(done)
		local format = "png"
		render.render_plantuml(format, function(render_result)
			assert.is_not_nil(render_result, "Expected a render result but got nil")

			assert.is_not_nil(render_result.content, "Render result should contain content")

			if render_result.is_image then
				local result_path = vim.fn.filereadable(render_result.content)
				assert.is.truthy(result_path, "Expected output file to exist: " .. render_result.content)
			else
				assert(render_result.content:match("@startuml"), "Expected UML start in content")
				assert(render_result.content:match("@enduml"), "Expected UML end in content")
			end

			assert.are.equal(render_result.line_number, 7, "Rendered diagram should align to the correct line number")

			done()
		end)
	end)
end)
