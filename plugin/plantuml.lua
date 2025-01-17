if vim.g.loaded_plantuml_plugin then
	return
end
vim.g.loaded_plantuml_plugin = true

vim.api.nvim_create_user_command("PlantUMLRender", function(opts)
	require("plantuml").render_plantuml(
		opts.args ~= "" and opts.args or nil,
		require("plantuml.inserters").insert_rendered_diagram
	)
end, {
	nargs = "?",
	complete = function(arg_lead)
		local formats = vim.tbl_keys(require("plantuml.config").options.format_extension_map)
		return vim.tbl_filter(function(item)
			return vim.startswith(item, arg_lead)
		end, formats)
	end,
})

vim.api.nvim_create_user_command("PlantUMLLiveDisplay", function(opts)
	local utils = require("plantuml.utils")
	local render = require("plantuml.render")
	local finders = require("plantuml.finders")

	local last_content = nil

	local function display_callback(result)
		if not result.is_image then
			if result.content == last_content then
				return
			end
			last_content = result.content

			utils.update_or_create_buffer(result)
		end
	end

	local function render_plantuml()
		local block = finders.find_plantuml_block()
		if block and block.content ~= last_content then
			render.render_plantuml(opts.args ~= "" and opts.args or "utxt", display_callback)
		end
	end

	render_plantuml()

	local augroup = vim.api.nvim_create_augroup("PlantUMLLiveDisplay", { clear = true })
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = augroup,
		buffer = vim.api.nvim_get_current_buf(),
		callback = render_plantuml,
	})

	vim.api.nvim_create_autocmd("BufUnload", {
		group = augroup,
		buffer = vim.api.nvim_get_current_buf(),
		callback = function()
			utils.clear_output_buffer()
			vim.api.nvim_del_augroup_by_name("PlantUMLLiveDisplay")
		end,
	})
end, {
	nargs = "?",
	complete = function(arg_lead)
		local formats = vim.tbl_filter(function(format)
			return vim.tbl_contains({ "txt", "utxt" }, format)
		end, vim.tbl_keys(require("plantuml.config").options.format_extension_map))
		return vim.tbl_filter(function(item)
			return vim.startswith(item, arg_lead)
		end, formats)
	end,
})
