#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

static int _unpack(lua_State *L)
{
	uint32_t msgid;
	const char * data;
	const char * msg;
	size_t size;
	
	uint8_t * buffer = (uint8_t *)malloc(4);
	
	data = luaL_checklstring(L, 1, &size);//返回字符串长度
	
	memcpy(buffer, data, 4);
	msg = data + 4;

	msgid = (buffer[0] << 24) | (buffer[1] << 16) | (buffer[2] << 8) | buffer[3];
	
	lua_newtable(L);
	
	lua_pushstring(L, "msgid");
	lua_pushinteger(L, msgid);
	lua_settable(L, -3);
	
	lua_pushstring(L, "msg");
	lua_pushstring(L, msg);
	lua_settable(L, -3);
	//free(buffer);
	return 1;
}

static int _pack(lua_State *L)
{
	uint32_t msgid;
	const char * msg;
	size_t size;
	uint8_t * buffer;
	
	msgid = luaL_checkinteger(L, 1);
	msg = luaL_checklstring(L, 2, &size);
	if (size > 0x10000) {//2^16bit=2byte
		return luaL_error(L, "Invalid size (too long) of data : %d", (int)size);
	}
	
	buffer = (uint8_t*)malloc(size + 4);
	
	buffer[0] = (msgid >> 24) & 0xff;
	buffer[1] = (msgid >> 16) & 0xff;
	buffer[2] = (msgid >> 8) & 0xff;
	buffer[3] = msgid & 0xff;
	
	memcpy(buffer + 4, msg, size);
	lua_pushlstring(L, (const char *)buffer, size + 4);
	//free(buffer);
	return 1;
}

static const struct luaL_Reg lib[] =
{
	{"pack", _pack},
	{"unpack", _unpack},
	{NULL, NULL}
};

int luaopen_msgpack_core(lua_State *L)
{
	luaL_newlib(L,lib);
	return 1;
}

