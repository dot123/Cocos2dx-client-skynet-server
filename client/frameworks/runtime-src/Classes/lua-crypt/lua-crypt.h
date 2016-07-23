#ifndef __LUA_CRYPT_H_
#define __LUA_CRYPT_H_

#if __cplusplus
extern "C" {
#endif

#include "lauxlib.h"

	int luaopen_crypt(lua_State *L);

#if __cplusplus
}
#endif

#endif