local skynet  = require "skynet"
local netpack = require "netpack"
local socket  = require "socket"
-- local bit32 = require "bit32"
local MSG = require "MSGTYPE"
local p = require "p.core"

local WATCHDOG
local CMD = {}
local client_fd

local function send_pack(TYPE,MSG)
	-- local size = #pack
	-- local package = string.char(bit32.extract(size,8,8)) .. string.char(bit32.extract(size,0,8)) .. pack

	-- local package = string.pack(">s2", pack)
	-- socket.write(client_fd, package)

	local pack = p.pack(1,TYPE,MSG)
	local data = p.unpack(pack)
	skynet.error("[LOG]",os.date("%m-%d-%Y %X"),"send ok",data.v,data.p)
	socket.write(client_fd, netpack.pack(pack))
end

local function analyze(data)

end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		return skynet.tostring(msg,sz)
	end,
	dispatch = function (session, address, text)
		local data = p.unpack(text)
		analyze(data)
		skynet.error("[LOG]",os.date("%m-%d-%Y %X"),"receive ok",data.v,data.p)
	end
}

function CMD.start(conf,userinfo)
	local fd = conf.client
	local gate = conf.gate
	WATCHDOG = conf.watchdog
	skynet.error("[LOG]",os.date("%m-%d-%Y %X"),string.format("fd(%d)", fd), "start")

	client_fd = fd
	skynet.call(gate, "lua", "forward", fd)
	skynet.call(WATCHDOG, "lua", "agent", fd, skynet.self())
	skynet.sleep(10)
	skynet.call(".heartbeat", "lua", "start", fd)
end

function CMD.disconnect()
	-- todo: do something before exit
	-- skynet.exit() --有agent_pool,不需要退出服务
	skynet.error("[LOG]",os.date("%m-%d-%Y %X"),string.format("fd(%d)", client_fd),"disconnect")
	skynet.call(".heartbeat", "lua", "die", client_fd)
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)
