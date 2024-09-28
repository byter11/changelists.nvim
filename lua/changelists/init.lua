local util = require("changelists.util")

local function setup()
	vim.fn.sign_define("mySign", { text = "?", texthl = "mySign" })
	vim.cmd([[highlight mySign guifg=#C0FFEE]])
end

function Global_lua_function()
	print("Global: hello")
end

local function local_lua_function()
	vim.fn.sign_place(5, "", "mySign", "%", { lnum = 35 })
end

-- :Mark 5-10
vim.api.nvim_create_user_command("Mark", function(input)
	local a, b = util.splitRange(input.args)
	vim.fn.sign_placelist(util.signPlaces(a, b))
end, { nargs = 1, bang = true, desc = "command to add highlights to a range of lines" })

-- :Unmark 5-10
vim.api.nvim_create_user_command("Unmark", function(input)
	local a, b = util.splitRange(input.args)
	vim.fn.sign_unplacelist(util.signPlaces(a, b))
end, { nargs = 1, bang = true, desc = "command to remove highlights to a range of lines" })

vim.keymap.set("n", "M-C-G", local_lua_function, { desc = "Run local_lua_function.", remap = false })

local augroup = vim.api.nvim_create_augroup("highlight_cmds", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "rubber",
	group = augroup,
	-- There can be a 'command', or a 'callback'. A 'callback' will be a reference to a Lua function.
	command = "highlight String guifg=#FFEB95",
	--callback = function()
	--  vim.api.nvim_set_hl(0, 'String', {fg = '#FFEB95'})
	--end
})

return {
	setup = setup,
	local_lua_function = local_lua_function,
}
