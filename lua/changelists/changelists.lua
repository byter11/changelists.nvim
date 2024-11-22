local async = require("gitsigns.async")
local Hunks = require("gitsigns.hunks")
local Actions = require("gitsigns.actions")
local cache = require("gitsigns.cache").cache
local util = require("changelists.util")
local signs = require("changelists.signs")

local M = {}

--- @class (exact) Changelists.Change
--- @field hunk Gitsigns.Hunk.Hunk
--- @field list_id integer

---@type table<integer, Changelists.Change[]>
M.marked_hunks = {}

--- @param buffer integer
local function refresh_signs(buffer)
	vim.fn.sign_unplace("changelists", { buffer = vim.api.nvim_get_current_buf() })
	local hunks = M.marked_hunks[buffer]
	for _, mHunk in ipairs(hunks) do
		signs.sign(mHunk.hunk.added.start, mHunk.list_id)
	end
end

function Print_changelist()
	--print(vim.inspect(M.marked_hunks))
	for i in next, M.marked_hunks do
		print(i)
		-- for _, h in ipairs(hunks) do
		-- print(h.hunk.added.start, h.hunk.vend, h.list_id)
		-- end
	end
end

--- @param bCache Gitsigns.CacheEntry
--- @param buffer integer
local function update_marks(bCache, buffer)
	if not M.marked_hunks[buffer] then
		M.marked_hunks[buffer] = {}
		return
	end

	if not bCache.hunks then
		return
	end
	local mHunks = M.marked_hunks[buffer]
	local newHunks = {}
	for _, bHunk in ipairs(bCache.hunks) do
		local newHunk
		for _, mHunk in ipairs(mHunks) do
			if util.comp_lines(mHunk.hunk, bHunk) then
				newHunk = { hunk = bHunk, list_id = mHunk.list_id }
				break
			end
		end

		if newHunk then
			table.insert(newHunks, newHunk)
		else
			table.insert(newHunks, { hunk = bHunk, list_id = signs.default })
		end
	end

	M.marked_hunks[buffer] = newHunks
end

local function move(list_id)
	list_id = list_id or signs.default

	local buf = vim.api.nvim_get_current_buf()
	local lnum = vim.api.nvim_win_get_cursor(0)[1]
	local bCache = cache[buf]
	if not bCache or not bCache.hunks then
		return
	end

	local hunk, _ = Hunks.find_hunk(lnum, bCache.hunks)
	if not hunk then
		return
	end

	local hunks = M.marked_hunks[buf]
	if not hunks then
		hunks = {}
	end

	for i, mHunk in ipairs(hunks) do
		if util.comp_lines(mHunk.hunk, hunk) then
			table.remove(hunks, i)
		end
	end

	table.insert(hunks, { list_id = list_id, hunk = hunk })
	M.marked_hunks[buf] = hunks

	update_marks(bCache, buf)
	refresh_signs(buf)
end

local function show(list_id)
	list_id = list_id or signs.default

	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].buftype = "nofile" -- No file associated
	vim.bo[buf].swapfile = false -- No swapfile
	vim.bo[buf].bufhidden = "wipe" -- Buffer is wiped when hidden

	local output = {}
	for _, changes in next, M.marked_hunks do
		local sHunks = {}
		for _, mHunk in ipairs(changes) do
			if mHunk.list_id == list_id then
				table.insert(sHunks, mHunk.hunk)
			end
		end

		local patch = Hunks.create_patch("", sHunks, "")
		for _, p in ipairs(patch) do
			table.insert(output, p)
		end
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = math.floor(vim.o.columns * 0.8),
		height = math.floor(vim.o.lines * 0.8),
		col = math.floor(vim.o.columns * 0.1),
		row = math.floor(vim.o.lines * 0.1),
		style = "minimal",
	})
end

local function stage(list_num)
	print("Staging", list_num)

	for k, hunks in next, M.marked_hunks do
		local bcache = cache[k]
		if bcache then
			local sHunks = {}
			for i, mHunk in ipairs(hunks) do
				if mHunk.list_id == list_num then
					table.insert(sHunks, mHunk.hunk)
				end
			end
			async.run(function()
				bcache.git_obj:stage_hunks(sHunks, false)
			end)
		end
	end
end

local function setup()
	vim.api.nvim_create_autocmd("User", {
		pattern = "GitSignsUpdate",
		callback = function(args)
			if not args.data then
				return
			end
			local buffer = args.data.buffer
			local bCache = cache[buffer]
			if not bCache then
				return
			end

			update_marks(bCache, buffer)
			refresh_signs(buffer)
		end,
	})
end

return {
	setup = setup,
	move = move,
	stage = stage,
	show = show,
}
