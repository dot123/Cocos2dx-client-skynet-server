#!/usr/bin/env lua

local p = require("p.core")
-- data = p.add(15,25)
-- print(data.key);
-- for i,v in ipairs(data.sub_array) do 
-- 	print(i,v) 
-- end

msg = "hello"
x = p.unpack(p.pack(65535,4294967295,msg))
print(x.v,x.p,x.msg)