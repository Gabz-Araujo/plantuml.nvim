local plenary_path = vim.fn.stdpath("data") .. "/site/pack/vendor/start/plenary.nvim"
if vim.fn.empty(vim.fn.glob(plenary_path)) > 0 then
	vim.fn.system({ "git", "clone", "https://github.com/nvim-lua/plenary.nvim", plenary_path })
end

vim.opt.runtimepath:append(".")
vim.opt.runtimepath:append(plenary_path)
require("plenary.busted")
