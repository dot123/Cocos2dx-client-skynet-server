local skynet  = require "skynet"
local netpack = require "netpack"

local gate  --门服务
local auth 	--验证服务

local CMD = {}
local SOCKET = {}

local agent = {}

-- 有客户端链接请求过来
function SOCKET.open(fd, addr)
	print(string.format("[watchdog] a new client connecting fd(%d) address(%s)", fd, addr))

	-- if agent[fd] == nil then
	-- 	agent[fd] = skynet.call(".agent_pool", "lua", "get_agent")
	-- end
	-- skynet.call(agent[fd], "lua", "start", { gate = gate, client = fd, watchdog = skynet.self() })

	-- 开启接收客户端的数据
	skynet.call(gate, "lua", "accept", fd)
end

local function close_agent(fd)
	local a = agent[fd]
	agent[fd] = nil
	if a then
		skynet.call(".agentpool", "lua", "freeAgent",a)
		skynet.call(gate, "lua", "kick", fd)
		-- disconnect never return
		skynet.call(a, "lua", "disconnect")
	end
end

function SOCKET.close(fd)
	print("socket close",fd)
	close_agent(fd)
end

function SOCKET.error(fd, msg)
	print("socket error",fd, msg)
	close_agent(fd)
end

function SOCKET.warning(fd, size)
	-- size K bytes havn't send out in fd
	print("socket warning", fd, size)
end

function SOCKET.data(fd, msg)

end

function CMD.start(conf)
	conf.auth = auth
	skynet.call(gate, "lua", "open" , conf)
end

function CMD.close(fd)
	close_agent(fd)
end

function CMD.agent(fd, a)
	if agent[fd] == nil then
		agent[fd] = a
	else
		assert(string.format("fd( %d ) agent is not nil",fd))
	end
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
		if cmd == "socket" then
			local f = SOCKET[subcmd]
			f(...)
			-- socket api don't need return
		else
			local f = assert(CMD[cmd])
			skynet.ret(skynet.pack(f(subcmd, ...)))
		end
	end)

	gate = skynet.newservice("gated")
	auth = skynet.newservice("authservice")
end)
