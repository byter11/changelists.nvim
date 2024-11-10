--- @class (exact) Changelist
--- @field id integer
--- @field name string
--- @field sign string

---@type table<integer, Changelist>
local lists = {
	[0] = {
		id = 0,
		name = "Changes",
		sign = "CL_CHANGES",
	},
}

local function sign(linenum, cl)
	print("sign", linenum)
	cl = cl or lists[0].sign
	vim.fn.sign_place(linenum, "changelists", cl, "%", { lnum = linenum })
end

local function setup()
	local augroup = vim.api.nvim_create_augroup("changelists", { clear = true })

	vim.api.nvim_create_autocmd("ColorScheme", {
		pattern = "rubber",
		group = augroup,
		command = "highlight String guifg=#FFEB95",
	})

	for _, cl in pairs(lists) do
		vim.fn.sign_define(cl.sign, { text = tostring(cl.id), texthl = cl.name })
		vim.cmd([[highlight Changes guifg=#C0FFEE]])
	end
end

return {
	sign = sign,
	setup = setup,
}
