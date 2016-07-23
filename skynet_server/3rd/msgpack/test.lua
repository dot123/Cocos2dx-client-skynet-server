#!/usr/bin/env lua
local msgpack = require("msgpack.core")

local msgid = 1101
local msg = "hello skynet"
x = msgpack.unpack(msgpack.pack(msgid, msg))
print(x.msgid, x.msg)
