local function splitRange(range)
	local start, finish = range:match("(%d+)%-(%d+)")
	if start and finish then
		return tonumber(start), tonumber(finish)
	else
		return nil, nil
	end
end

--- @param a Gitsigns.Hunk.Hunk
--- @param b Gitsigns.Hunk.Hunk
local function comp_lines(a, b)
	local pairs = {}
	if a.added and b.added then
		table.insert(pairs, { a.added.lines, b.added.lines })
	end
	if a.removed and b.removed then
		table.insert(pairs, { a.removed.lines, b.removed.lines })
	end

	for _, p in ipairs(pairs) do
		local arr1, arr2 = p[1], p[2]
		if #arr1 ~= #arr2 then
			return false
		end

		for i = 1, #arr1 do
			if arr1[i] ~= arr2[i] then
				return false
			end
		end
	end

	return true
end

return {
	splitRange = splitRange,
	comp_lines = comp_lines,
}
