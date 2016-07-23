local skynet = require "skynet"
require "skynet.manager"
local mysql = require "mysql"

local db 
local CMD = {}
local sql = nil
local result = nil
local tableName = "simple"

-- CREATE TABLE simple(
--    pid INT NOT NULL AUTO_INCREMENT,
--    username VARCHAR(10) NOT NULL,
--    userid VARCHAR(64) NOT NULL,
--    password VARCHAR(32) NOT NULL,
--    registdate DATE,
--    PRIMARY KEY (pid)
-- );

local function dump(obj)
    local getIndent, quoteStr, wrapKey, wrapVal, dumpObj
    getIndent = function(level)
        return string.rep("\t", level)
    end
    quoteStr = function(str)
        return '"' .. string.gsub(str, '"', '\\"') .. '"'
    end
    wrapKey = function(val)
        if type(val) == "number" then
            return "[" .. val .. "]"
        elseif type(val) == "string" then
            return "[" .. quoteStr(val) .. "]"
        else
            return "[" .. tostring(val) .. "]"
        end
    end
    wrapVal = function(val, level)
        if type(val) == "table" then
            return dumpObj(val, level)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
        end
        level = level + 1
        local tokens = {}
        tokens[#tokens + 1] = "{"
        for k, v in pairs(obj) do
            tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
        end
        tokens[#tokens + 1] = getIndent(level - 1) .. "}"
        return table.concat(tokens, "\n")
    end
    return dumpObj(obj, 0)
end

function CMD.query(sql)
	skynet.error("--- dbserver query:" .. sql)
    local r = db:query(sql)
    skynet.error("query result = ",dump(r))
    return r
end

function CMD.login(userid,name,password)
    sql = "select * from "..tableName.." where userid = '" .. userid .. "'"
    result = CMD.query(sql)
    local r = nil
    local username = nil
    if #result > 0 then
        r = result[1]["userid"]
        username = result[1]["username"]
    end
    if not r then
        sql = "INSERT INTO "..tableName.." (userid,username,password,registdate)values('" .. userid .. "','".. name .. "','" .. password .. "',NOW()" .. ")"
        result = CMD.query(sql)
        r = userid
    else
        if username ~= name then
            sql = "UPDATE "..tableName.." SET username = '" .. name .. "'".. " WHERE userid = '" .. r .. "'"
            result = CMD.query(sql)
            return name
        end
    end

    return r
end
                
skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = CMD[cmd]
		skynet.ret(skynet.pack(f(...)))
	end)

	db = mysql.connect {
		host = "127.0.0.1",
		port = 3306,
		database = "simpledb",
		user = "root",
		password = "1234",
		max_packet_size = 1024 * 1024
	}
	if not db then
		skynet.error("failed to connect mysql")
	end

	skynet.register ".dbservice"
end)
		
