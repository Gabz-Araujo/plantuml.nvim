local M = {}

local config = require("plantuml.config")

function M.setup(opts)
	opts = opts or {}
	config.setup(opts)
end

M.render_plantuml = require("plantuml.render").render_plantuml
M.insert_rendered_diagram = require("plantuml.inserters").insert_rendered_diagram

return M
