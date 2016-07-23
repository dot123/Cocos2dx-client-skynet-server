local skynet  = require "skynet"
local cplayer = require "player_define"
require "skynet.manager"
local command = {}

function command.start(msg)

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

	skynet.register ".player_manage"
end)
