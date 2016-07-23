--
-- 	验证客户端链接
--
local skynet  = require "skynet"
local queue   = require "skynet.queue"
local netpack = require "netpack"
local socket  = require "socket"

local MSG = require "MSGTYPE"
local p = require "p.core"
local locker = queue()

local command = {}

local function send_pack(fd,TYPE,MSG)
	local pack = p.pack(1,TYPE,MSG)
	local data = p.unpack(pack)
	skynet.error("[LOG]",os.date("%m-%d-%Y %X"),"send ok",data.v,data.p)
	socket.write(fd, netpack.pack(pack))
end

local function auth_ok(conf,info)
	local agent = skynet.call(".agentpool", "lua", "getAgent")
	if agent then 
		print("-------------------------------------------------------")
		skynet.call(agent, "lua", "start", conf, info)
	end
end

function command.data(fd,gate,watchdog,data)
	-- 保证消息按顺序执行
	locker(function()
		local d = p.unpack(data)
		if d.p == MSG.ROLE_LOGIN_REQUEST_CS then
			local conf = {client = fd,gate = gate,watchdog = watchdog}
			local ok,result,info = pcall(skynet.call,".protocolservice", "lua", "login", d.msg)
			send_pack(fd,MSG.ROLE_LOGIN_RESPONSE_SC,result)
			if info then
				auth_ok(conf,info)
			end
		end
	end)
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
end)
