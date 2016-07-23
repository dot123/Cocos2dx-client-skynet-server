#ifdef __cplusplus
extern "C" {
#endif

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include <lualib.h>
#include <lauxlib.h>
#include "msgpack.h"

#if LUA_VERSION_NUM == 501

#define lua_rawlen lua_objlen
#define luaL_newlib(L ,reg) luaL_register(L,"msgpack.c",reg)
#define luaL_buffinit(L , _ ) 
#define luaL_prepbuffsize(b , cap) malloc(cap)
#define _Free(p) free(p)
#undef luaL_addsize
#define luaL_addsize(b , len) lua_pushlstring(L, temp , len) ; free(temp)
#define luaL_pushresult(b) 
#define luaL_checkversion(L)

#else

#define _Free(p)

#endif

static int _unpack(lua_State *L)
{
	uint32_t msgid;
	const char * data;
	const char * msg;
	size_t size;
	
	uint8_t * buffer = (uint8_t *)malloc(4);
	data = luaL_checklstring(L, 1, &size);
	memcpy(buffer, data, 4);
	msg = data + 4;
	msgid = (buffer[0] << 24) | (buffer[1] << 16) | (buffer[2] << 8) | buffer[3];
	free(buffer);
	lua_newtable(L);
	
	lua_pushstring(L, "msgid");
	lua_pushinteger(L, msgid);
	lua_settable(L, -3);
	
	lua_pushstring(L, "msg");
	lua_pushstring(L, msg);
	lua_settable(L, -3);
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
	free(buffer);
	return 1;
}
//打包数据格式
//string.pack(">s2", pack)
static int _p(lua_State *L)
{
	const char * msg;
	size_t size;
	uint8_t * buffer;
	msg = luaL_checklstring(L, 1, &size);
	if (size > 0x10000) {//2^16bit=2byte
		return luaL_error(L, "Invalid size (too long) of data : %d", (int)size);
	}
	buffer = (uint8_t *)malloc(size + 2);
	buffer[0] = (size >> 8) & 0xff;
	buffer[1] = size & 0xff;

	memcpy(buffer + 2, msg, size);
	lua_pushlstring(L, (const char *)buffer, size + 2);
	free(buffer);
	return 1;
}
//打包数据格式
//local size = #v + 4
//local package = string.pack(">I2", size)..v..string.pack(">I4", session)
static int _s(lua_State *L)
{
	const char * msg;
	uint32_t session;
	uint16_t len;
	size_t size;
	uint8_t * buffer;
	msg = luaL_checklstring(L, 1, &size);
	len = size + 4;
	if (len > 0x10000) {//2^16bit=2byte
		return luaL_error(L, "Invalid size (too long) of data : %d", (int)size);
	}
	session = luaL_checkinteger(L, 2);

	buffer = (uint8_t *)malloc(size + 6);
	buffer[0] = (len >> 8) & 0xff;
	buffer[1] = len & 0xff;
	buffer[size + 6 - 4] = (session >> 24) & 0xff;
	buffer[size + 6 - 3] = (session >> 16) & 0xff;
	buffer[size + 6 - 2] = (session >> 8) & 0xff;
	buffer[size + 6 - 1] = session & 0xff;

	memcpy(buffer + 2, msg, size);
	lua_pushlstring(L, (const char *)buffer, size + 6);
	free(buffer);
	return 1;
}
//解包数据格式
//local size = #v - 5
//local content, ok, session = string.unpack("c"..tostring(size).."B>I4", v)
static int _r(lua_State *L)
{
	const char * data;
	size_t size;
	uint8_t * buffer;
	uint32_t session;
	data = luaL_checklstring(L, 1, &size);
	buffer = (uint8_t *)malloc(4);
	memcpy(buffer, data + size - 4, 4);
	session = (buffer[0] << 24) | (buffer[1] << 16) | (buffer[2] << 8) | buffer[3];
	free(buffer);
	lua_newtable(L);
	lua_pushstring(L, "data");
	lua_pushlstring(L, data, size - 4);
	lua_settable(L, -3);

	lua_pushstring(L, "session");
	lua_pushinteger(L, session);
	lua_settable(L, -3);

	lua_pushstring(L, "size");
	lua_pushinteger(L, size - 4);
	lua_settable(L, -3);
	return 1;
}

int luaopen_msgpack_core(lua_State *L) 
{
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "unpack", _unpack },
		{ "pack", _pack },
		{ "p", _p },
		{ "s", _s },
		{ "r", _r },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
#ifdef __cplusplus
}
#endif