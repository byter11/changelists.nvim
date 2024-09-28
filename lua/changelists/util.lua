local function splitRange(range)
	local start, finish = range:match("(%d+)%-(%d+)")
	if start and finish then
		return tonumber(start), tonumber(finish)
	else
		return nil, nil
	end
end

local function signPlaces(start, finish)
	local objects = {}
	for i = start, finish do
		table.insert(objects, {
			id = i,
			name = "mySign",
			buffer = "%",
			lnum = i,
		})
	end
	return objects
end

return {
	splitRange = splitRange,
	signPlaces = signPlaces,
}
