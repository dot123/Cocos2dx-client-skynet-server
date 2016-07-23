local skynet	= require "skynet"
local netpack	= require "netpack"
local socket	= require "socket"
local queue  	= require "skynet.queue"
require "skynet.manager"	-- import skynet.register
local p = require "p.core"
local locker = queue()
local command = {}
local client_fd = {}

local function sendHeartBeat(fd)
	local pack = p.pack(1,10000,"heartbeat")
	local data = p.unpack(pack)
	skynet.error("[LOG]",os.date("%m-%d-%Y %X"),"send ok",data.msg)
	socket.write(fd, netpack.pack(pack))
end

--[[--
从表格中删除指定值，返回删除的值的个数

~~~ lua

local array = {"a", "b", "c", "c"}
print(table.removebyvalue(array, "c", true)) -- 输出 2

~~~

]]

-- end --

function table.removebyvalue(array, value, removeall)
    local c, i, max = 0, 1, #array
    while i <= max do
        if array[i] == value then
            table.remove(array, i)
            c = c + 1
            i = i - 1
            max = max - 1
            if not removeall then break end
        end
        i = i + 1
    end
    return c
end

local function startFork()
	skynet.fork(function()
		while true do
			for i = 1,#client_fd do
				sendHeartBeat(client_fd[i])
			end
			skynet.sleep(500)
		end
	end)
end

function command.start(fd)
	table.insert(client_fd,fd)
end

function command.die(fd)
	table.removebyvalue(client_fd,fd)
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
	startFork()
	skynet.register ".heartbeat"
end)
