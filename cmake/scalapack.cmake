include(FetchContent)
include(GNUInstallDirs)

if(NOT PROJECT_IS_TOP_LEVEL)
  message(STATUS "${PROJECT_NAME} ${PROJECT_VERSION} deferring to ${CMAKE_PROJECT_NAME} for SCALAPACK")
  return()
endif()

if(find_scalapack)

  if(NOT DEFINED SCALAPACK_VENDOR AND DEFINED ENV{MKLROOT})
    set(SCALAPACK_VENDOR MKL)
  endif()

  if(MKL IN_LIST SCALAPACK_VENDOR)
    if(intsize64)
      list(APPEND SCALAPACK_VENDOR MKL64)
    endif()
  endif()

  if(find_static)
    list(APPEND SCALAPACK_VENDOR STATIC)
  endif()

  find_package(SCALAPACK COMPONENTS ${SCALAPACK_VENDOR})

endif()

if(SCALAPACK_FOUND)
  return()
endif()

# -- build SCALAPACK

include(${CMAKE_CURRENT_LIST_DIR}/GitSubmodule.cmake)
git_submodule("${PROJECT_SOURCE_DIR}/scalapack")

FetchContent_Declare(scalapack
SOURCE_DIR ${PROJECT_SOURCE_DIR}/scalapack
)

FetchContent_MakeAvailable(scalapack)
