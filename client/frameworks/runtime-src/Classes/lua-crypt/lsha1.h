#ifndef __LUA_LSHA1_H_
#define __LUA_LSHA1_H_

#if __cplusplus
extern "C" {
#endif

#include "lauxlib.h"

	int lsha1(lua_State *L);
	int lhmac_sha1(lua_State *L);

#if __cplusplus
}
#endif

#endif