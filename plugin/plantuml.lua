if vim.g.loaded_plantuml_plugin then
	return
end
vim.g.loaded_plantuml_plugin = true

vim.api.nvim_create_user_command("PlantumlRender", function(opts)
	require("plantuml").render_plantuml(
		opts.args ~= "" and opts.args or nil,
		require("plantuml.inserters").insert_rendered_diagram
	)
end, {
	nargs = "?",
	complete = function(arg_lead)
		-- Provide autocompletion for output formats
		local formats = vim.tbl_keys(require("plantuml.config").options.format_extension_map)
		return vim.tbl_filter(function(item)
			return vim.startswith(item, arg_lead)
		end, formats)
	end,
})

vim.api.nvim_create_user_command("PlantUMLDisplay", function()
	require("plantuml").render_plantuml(require("plantuml.inserters").display_image_in_buffer)
end, {})
