local skynet  = require "skynet"
local netpack = require "netpack"
local socket  = require "socket"
require "skynet.manager"

local MSG = require "MSGTYPE"
local CMD = {}

local root = skynet.getenv("root") .. "../source/res/"
local protocolFileName  = {"message"}
local protobuf = require "protobuf"

function CMD.encode(typename,t,func , ...)
	 return protobuf.encode(typename,t,func , ...)
end

function CMD.decode(message, t , func , ...)
	local message = protobuf.decode(message, t , func , ...)
	if message == false then
		print("[LOG]",os.date("%m-%d-%Y %X"),"protocbuf decode error")
		return "" --解析protocbuf错误
	end
	return message
end

function CMD.login(data)
	local r = CMD.decode("message.login", data)
	if r == false then
		return CMD.encode("message.result", {id = MSG.RESULT_PROTOCOL_ERROR}) --解析protocbuf错误
	end
	local ok, result = pcall(skynet.call,".dbservice","lua","login",r.userid,r.name,r.password)
	print("[LOG]",os.date("%m-%d-%Y %X"),"mysql login result",result)
	if not result then
		return CMD.encode("message.result", {id = MSG.RESULT_MYSQL_ERROR}) --mysql错误
	end
	return CMD.encode("message.result", {id = MSG.RESULT_OK}),r --ok
end

local function registerAllProtocol()
	for _, v in pairs(protocolFileName) do
		local pb = io.open(root..v..".pb","rb")
		local buffer = pb:read "*a"
		pb:close()
		protobuf.register(buffer)
	end
end

skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = CMD[cmd]
		skynet.ret(skynet.pack(f(...)))
	end)
	registerAllProtocol()
	skynet.register ".protocolservice"
end)
