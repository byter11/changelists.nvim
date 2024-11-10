local signs = require("changelists.signs")
local cmd = require("changelists.cmd")
local changelists = require("changelists.changelists")

return {
	setup = function()
		signs.setup()
		changelists.setup()
		cmd.setup()
	end,
}
