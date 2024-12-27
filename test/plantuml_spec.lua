local assert = require("luassert")
local plantuml = require("plantuml")

describe("plantuml", function()
	local helpers
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

		helpers = plantuml._test_helpers()
	end)

	after_each(function()
		vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
	end)

	it("should find PlantUML fence", function()
		vim.api.nvim_win_set_cursor(0, { 4, 0 })
		local fence, err = helpers.find_plantuml_fence()
		assert.is_nil(err)
		assert.are.same({
			content = "@startuml\nA -> B: Hello\nB -> A: Hi there\n@enduml",
			start_line = 3,
			end_line = 8,
		}, fence)
	end)

	it("should build correct PlantUML command", function()
		local command = helpers.build_plantuml_command("/tmp/input.puml", "/tmp/output")
		assert.are.equal("plantuml -utxt -o /tmp/output /tmp/input.puml", command)
	end)

	it("should sanitize input", function()
		local sanitized = helpers.sanitize_input("/tmp/input;rm -rf /")
		assert.are.equal("/tmp/inputrm -rf /", sanitized)
	end)

	it("should render PlantUML diagram", function(done)
		plantuml.render_plantuml(function(graph, line_number)
			assert.is_not_nil(graph)
			assert.are.equal(7, line_number)
			done()
		end)
	end)
end)
