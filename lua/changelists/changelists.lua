local Hunks = require("gitsigns.hunks")
local Actions = require("gitsigns.actions")
local cache = require("gitsigns.cache").cache
local util = require("changelists.util")
local signs = require("changelists.signs")

local M = {}

--- @class (exact) Changelists.Change
--- @field hunk Gitsigns.Hunk.Hunk
--- @field list_num integer

---@type table<integer, Changelists.Change[]>
M.marked_hunks = {}

--- @param buffer integer
local function refresh_signs(buffer)
	vim.fn.sign_unplace("changelists", { buffer = vim.api.nvim_get_current_buf() })
	local hunks = M.marked_hunks[buffer]
	for i, mHunk in ipairs(hunks) do
		signs.sign(mHunk.hunk.added.start)
	end
end

function Print_changelist()
	local hunks = M.marked_hunks[vim.api.nvim_get_current_buf()]
	if not hunks then
		return
	end

	for _, h in ipairs(hunks) do
		print(h.hunk.added.start, h.hunk.vend)
	end
end

local function move(list_num)
	list_num = list_num or 0

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
			M.marked_hunks[buf] = hunks
			return
		end
	end

	table.insert(hunks, { list_num = list_num, hunk = hunk })
	M.marked_hunks[buf] = hunks
end

local function stage(list_num)
	local buf = vim.api.nvim_get_current_buf()
	local hunks = M.marked_hunks[buf]
	if not hunks then
		return
	end

	for i, mHunk in ipairs(hunks) do
		Actions.stage_hunk({ mHunk.hunk.added.start, mHunk.hunk.vend })
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
				newHunk = { hunk = bHunk, list_num = mHunk.list_num }
				break
			end
		end

		if newHunk then
			table.insert(newHunks, newHunk)
		else
			table.insert(newHunks, { hunk = bHunk, list_num = 0 })
		end
	end

	M.marked_hunks[buffer] = newHunks
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

			print("cb")
			-- Update local copy of buffer cache
			update_marks(bCache, buffer)
			refresh_signs(buffer)
		end,
	})
end

return {
	setup = setup,
	move = move,
	stage = stage,
}
