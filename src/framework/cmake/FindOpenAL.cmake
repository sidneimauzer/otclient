# Try to find the OPENAL library
#  OPENAL_FOUND - system has OPENAL
#  OPENAL_INCLUDE_DIR - the OPENAL include directory
#  OPENAL_LIBRARY - the OPENAL library

FIND_PATH(OPENAL_INCLUDE_DIR NAMES AL/al.h)
SET(_OPENAL_STATIC_LIBS OpenAL.a al.a openal.a OpenAL32.a)
SET(_OPENAL_SHARED_LIBS OpenAL.dll al.dll openal.dll OpenAL32.dll OpenAL al openal OpenAL32)
IF(USE_STATIC_LIBS)
    FIND_LIBRARY(OPENAL_LIBRARY NAMES ${_OPENAL_STATIC_LIBS} ${_OPENAL_SHARED_LIBS})
ELSE()
    FIND_LIBRARY(OPENAL_LIBRARY NAMES ${_OPENAL_SHARED_LIBS} ${_OPENAL_STATIC_LIBS})
ENDIF()
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(OPENAL DEFAULT_MSG OPENAL_LIBRARY OPENAL_INCLUDE_DIR)
MARK_AS_ADVANCED(OPENAL_LIBRARY OPENAL_INCLUDE_DIR)
