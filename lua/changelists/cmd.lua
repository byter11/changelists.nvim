local cl = require("changelists.changelists")

---@class CLSubCmd
---@field impl fun(args:string[], opts: table)
---@field complete? fun(subcmd_arg_lead: string): string[]

---@type table<string, CLSubCmd>
local subcommand_tbl = {
	move_hunk = {
		impl = function(args)
			cl.move(args[1])
		end,
	},
	stage_list = {
		impl = function(args)
			cl.stage(args[1])
		end,
	},
	show_list = {
		impl = function(args)
			cl.show(args[1])
		end,
	},
}

---@param opts table
local function changelists(opts)
	local fargs = opts.fargs
	local subcommand_key = fargs[1]
	-- Get the subcommand's arguments, if any
	local args = #fargs > 1 and vim.list_slice(fargs, 2, #fargs) or {}

	local subcommand = subcommand_tbl[subcommand_key]
	if not subcommand then
		vim.notify("Changelists: Unknown command: " .. subcommand_key, vim.log.levels.ERROR)
		return
	end
	-- Invoke the subcommand
	subcommand.impl(args, opts)
end

local function setup()
	vim.api.nvim_create_user_command("Changelists", changelists, {
		nargs = "+",
		desc = "Git Changelists",
		complete = function(arg_lead, cmdline, _)
			-- Get the subcommand.
			local subcmd_key, subcmd_arg_lead = cmdline:match("^['<,'>]*Changelists[!]*%s(%S+)%s(.*)$")
			if
				subcmd_key
				and subcmd_arg_lead
				and subcommand_tbl[subcmd_key]
				and subcommand_tbl[subcmd_key].complete
			then
				-- The subcommand has completions. Return them.
				return subcommand_tbl[subcmd_key].complete(subcmd_arg_lead)
			end
			-- Check if cmdline is a subcommand
			if cmdline:match("^['<,'>]*Changelists[!]*%s+%w*$") then
				-- Filter subcommands that match
				local subcommand_keys = vim.tbl_keys(subcommand_tbl)
				return vim.iter(subcommand_keys)
					:filter(function(key)
						return key:find(arg_lead) ~= nil
					end)
					:totable()
			end
		end,
		bang = true, -- If you want to support ! modifiers
	})
end

return {
	setup = setup,
}
