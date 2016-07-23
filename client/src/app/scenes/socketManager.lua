cc.utils = require("framework.cc.utils.init")
cc.net   = require("framework.cc.net.init")

local messageManager = require("app.scenes.messageManager")
local pb  = require("app.libs.protobuf")
local MSG = require("app.scenes.MSGTYPE")
local protocolFileName = {"message"}
local config = {ip = "192.168.1.82",port = 3000}

socketManager = {}

function socketManager.registerAllProtocol()
    for _,v in ipairs(protocolFileName) do
        local path = cc.FileUtils:getInstance():fullPathForFilename("pb/"..v..".pb")
        -- pb.register_file(path)
        local p = io.open(path,"rb")
        local buffer = p:read "*a"
        p:close()
        pb.register(buffer)
    end
    --测试
    local stringbuffer = pb.encode("message.login",{userid = 1234578901,name = "hello"})
    local result = pb.decode("message.login", stringbuffer)
    local phone = pb.pack("message.login userid name",1,"123") 
    local number,name = pb.unpack("message.login userid name", phone)
    print("number:" .. number,"name:" .. name)
end

function socketManager:initSocket() 
	if not self._socket then
        self._socket = cc.net.SocketTCP.new(config.ip, config.port, false)
        self._socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECTED, handler(self,self.onConnected))
        self._socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSE, handler(self,self.onClose))
        self._socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSED, handler(self,self.onClosed))
        self._socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECT_FAILURE, handler(self,self.onConnectFailure))
        self._socket:addEventListener(cc.net.SocketTCP.EVENT_DATA, handler(self,self.onData))
    end
    self._socket:connect()
end

function socketManager:sendMessage(msg)
    self._socket:send(msg)
end

function socketManager:onConnected(__event)
    print("socket status: %s", __event.name)
end

function socketManager:onConnectFailure(__event)
    print("socket status: %s", __event.name)
end

function socketManager:onClose(__event)
    print("socket status: %s", __event.name)
end

function socketManager:onClosed(__event)
    print("socket status: %s", __event.name)
    self._socket = nil
end

function socketManager:createUser()
    local stringbuffer = pb.encode("message.login",{userid = 1234567890,name = "hello",password = "123456"})
    local message = messageManager:getProcessMessage (1,10001,stringbuffer)
    self._socket:send(message:getPack())
end

function socketManager:onData(__event)
    local maxLen,version,messageId,msg = messageManager:unpackMessage(__event.data)
    print("socket receive raw data:", maxLen,version,messageId,msg)
    -- print("messageId:", messageId)

    if messageId == MSG.ROLE_LOGIN_RESPONSE_SC then 
        local result = pb.decode("message.result", msg)
        print(result.id)
    elseif messageId == 10002 then 
 
    elseif messageId == 10003 then 

    elseif messageId == 10004 then 

    end
end

return socketManager