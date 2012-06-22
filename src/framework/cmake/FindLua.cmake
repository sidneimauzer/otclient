# Try to find the lua librairy
#  LUA_FOUND - system has lua
#  LUA_INCLUDE_DIR - the lua include directory
#  LUA_LIBRARY - the lua library
#  LUA_LIBRARIES - the lua library and it's dependencies

FIND_PATH(LUA_INCLUDE_DIR NAMES lua.h PATH_SUFFIXES lua51 lua5.1 lua)
FIND_LIBRARY(LUA_LIBRARY NAMES)
SET(_LUA_STATIC_LIBS liblua51.a liblua5.1.a liblua-5.1.a liblua.a )
SET(_LUA_SHARED_LIBS lua51.dll lua5.1.dll lua-5.1.dll lua.dll lua51 lua5.1 lua-5.1 lua)
IF(USE_STATIC_LIBS)
    FIND_LIBRARY(LUA_LIBRARY NAMES ${_LUA_STATIC_LIBS} ${_LUA_SHARED_LIBS})
ELSE()
    FIND_LIBRARY(LUA_LIBRARY NAMES ${_LUA_SHARED_LIBS} ${_LUA_STATIC_LIBS})
ENDIF()
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(Lua DEFAULT_MSG LUA_LIBRARY LUA_INCLUDE_DIR)
MARK_AS_ADVANCED(LUA_LIBRARY LUA_INCLUDE_DIR)