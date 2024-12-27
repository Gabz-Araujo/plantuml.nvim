if vim.g.loaded_plantuml_plugin then
	return
end
vim.g.loaded_plantuml_plugin = true

vim.api.nvim_create_user_command("PlantUMLRender", function()
	require("plantuml").render_plantuml(require("plantuml").insert_rendered_diagram)
end, {})

vim.api.nvim_create_user_command("PlantUMLDisplay", function()
	require("plantuml").render_plantuml(require("plantuml.inserters").display_image_in_buffer)
end, {})
