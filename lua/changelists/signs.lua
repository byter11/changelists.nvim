--- @class (exact) Changelist
--- @field id integer
--- @field name string
--- @field sign string

local default_list = "changes"

---@type table<integer, Changelist>
local lists = {
	[default_list] = {
		id = 0,
		name = "Changes",
		sign = "CL_CHANGES",
		symbol = "▢",
	},
}

local function sign(linenum, cl)
	cl = lists[cl] or lists[default_list]

	vim.fn.sign_place(linenum, "changelists", cl.sign, "%", { lnum = linenum })
end

local function setup(user_lists)
	local augroup = vim.api.nvim_create_augroup("changelists", { clear = true })

	vim.api.nvim_create_autocmd("ColorScheme", {
		pattern = "rubber",
		group = augroup,
		command = "highlight String guifg=#FFEB95",
	})

	lists = vim.tbl_deep_extend("force", lists, user_lists or {})
	for _, cl in pairs(lists) do
		vim.fn.sign_define(cl.sign, { text = tostring(cl.symbol), texthl = cl.name })
		vim.cmd([[highlight cl.name guifg=#C0FFEE]])
	end
end

return {
	sign = sign,
	setup = setup,
	lists = lists,
	default = default_list,
}
