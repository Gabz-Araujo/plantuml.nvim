local M = {}

M.options = {
	plantuml_path = "plantuml",
	output_format = "png",
	temp_dir = vim.fn.expand("$HOME") .. "/.cache/nvim/plantuml_temp",
	image_output_dir = nil,
	format_extension_map = {
		png = "png",
		svg = "svg",
		eps = "eps",
		pdf = "pdf",
		latex = "tex",
		txt = "txt",
		html = "html",
		utxt = "txt",
		xmi = "xmi",
	},
}

function M.setup(opts)
	opts = opts or {}
	M.options = vim.tbl_deep_extend("force", M.options, opts)
end

return M
