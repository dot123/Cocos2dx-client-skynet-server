local skynet  = require "skynet"
local cluster = require "cluster"

local max_client 			= skynet.getenv("max_client")
local harbor_name 			= skynet.getenv("harbor_name")
local client_port 			= skynet.getenv("client_port")
local debug_console_port	= skynet.getenv("debug_console_port")

skynet.start(function()
	skynet.error("Server start......")

	skynet.uniqueservice("protocolservice")
	skynet.uniqueservice("heartbeatservice")
	skynet.uniqueservice("dbservice")
	skynet.newservice("debug_console", debug_console_port)
	skynet.newservice("agentpool", max_client)

	local watchdog = skynet.newservice("watchdog")
	skynet.call(watchdog, "lua", "start", {

		port = client_port,
		maxclient = tonumber(max_client),
		nodelay = true, -- 客户端数据包立即发送，不使用延时 http://blog.163.com/zhangjie_0303/blog/static/990827062012718316231/
	})
	skynet.error("Watchdog listen on ", client_port)
	
	cluster.open(harbor_name)
	skynet.exit()
end)
