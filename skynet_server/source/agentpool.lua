local skynet = require "skynet"
require "skynet.manager"
local poolSize 	= ...
local agentPool = {}
local command   = {}
----------------------------------------------------------------------
local function createAgent()
	local a = skynet.newservice("agent")
	return a
end

local function initPool()
	for i = 1, poolSize, 1 do
		local a = createAgent()
		table.insert(agentPool, a)
	end
end

function command.getAgent()
	local a = table.remove(agentPool)
	if nil == a then
		a = createAgent()
	end
	return a
end

function command.freeAgent(agent)
	table.insert(agentPool, agent)
end

skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[cmd]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)
	initPool()
	skynet.register ".agentpool"
end)
