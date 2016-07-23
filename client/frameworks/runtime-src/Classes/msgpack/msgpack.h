#ifndef __LUA_MSGPACK_H_
#define __LUA_MSHPACK_H_

#if __cplusplus
extern "C" {
#endif

#include "lauxlib.h"

	int luaopen_msgpack_core(lua_State *L);

#if __cplusplus
}
#endif

#endif