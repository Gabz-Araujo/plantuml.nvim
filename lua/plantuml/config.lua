local Path = require("plenary.path")
local M = {}

M.options = {
	plantuml_path = "plantuml",
	output_format = "png",
	temp_dir = Path:new(vim.fn.stdpath("cache")):joinpath("nvim", "plantuml_temp").filename,
	image_output_dir = nil,
	format_extension_map = {
		png = "png",
		svg = "svg",
		eps = "eps",
		pdf = "pdf",
		latex = "tex",
		txt = "atxt",
		html = "html",
		utxt = "utxt",
		xmi = "xmi",
	},
}

function M.setup(opts)
	opts = opts or {}
	M.options = vim.tbl_deep_extend("force", M.options, opts)
end

return M
