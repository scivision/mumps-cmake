# Handle options for finding LAPACK

include(CheckSourceCompiles)
include(ExternalProject)
include(GNUInstallDirs)

if(NOT PROJECT_IS_TOP_LEVEL)
  message(STATUS "${PROJECT_NAME} ${PROJECT_VERSION} deferring to ${CMAKE_PROJECT_NAME} for LAPACK")
  return()
endif()

if(find_lapack)

if(NOT DEFINED LAPACK_VENDOR AND DEFINED ENV{MKLROOT})
  set(LAPACK_VENDOR MKL)
endif()

if(find_static)
  list(APPEND LAPACK_VENDOR STATIC)
endif()

find_package(LAPACK COMPONENTS ${LAPACK_VENDOR})

# GEMMT is recommeded in MUMPS User Manual if available
if(gemmt)

set(CMAKE_REQUIRED_INCLUDES ${LAPACK_INCLUDE_DIRS})

if(find_static AND NOT WIN32 AND
  MKL IN_LIST LAPACK_VENDOR AND
  CMAKE_VERSION VERSION_GREATER_EQUAL 3.24
  )
  set(CMAKE_REQUIRED_LIBRARIES $<LINK_GROUP:RESCAN,${LAPACK_LIBRARIES}>)
else()
  set(CMAKE_REQUIRED_LIBRARIES ${LAPACK_LIBRARIES})
endif()

if(BUILD_DOUBLE)
check_source_compiles(Fortran
"program check
use, intrinsic :: iso_fortran_env, only : real64
implicit none
external :: dgemmt
real(real64), dimension(2,2) :: A, B, C
CALL DGEMMT( 'U', 'N', 'T',  2 , 1 , 1._real64 , A , 2 , B , 2 , 1._real64 , C , 2 )
end program"
BLAS_HAVE_dGEMMT
)
endif()

if(BUILD_SINGLE)
check_source_compiles(Fortran
"program check
use, intrinsic :: iso_fortran_env, only : real32
implicit none
external :: sgemmt
real(real32), dimension(2,2) :: A, B, C
CALL SGEMMT( 'U', 'N', 'T',  2 , 1 , 1._real32 , A , 2 , B , 2 , 1._real32 , C , 2 )
end program"
BLAS_HAVE_sGEMMT
)
endif()

if(BUILD_COMPLEX)
check_source_compiles(Fortran
"program check
use, intrinsic :: iso_fortran_env, only : real32
implicit none
external :: cgemmt
complex(real32), dimension(2,2) :: A, B, C
CALL CGEMMT( 'U', 'N', 'T',  2 , 1 , 1._real32 , A , 2 , B , 2 , 1._real32 , C , 2 )
end program"
BLAS_HAVE_cGEMMT
)
endif()

if(BUILD_COMPLEX16)
check_source_compiles(Fortran
"program check
use, intrinsic :: iso_fortran_env, only : real64
implicit none
external :: zgemmt
complex(real64), dimension(2,2) :: A, B, C
CALL ZGEMMT( 'U', 'N', 'T',  2 , 1 , 1._real64 , A , 2 , B , 2 , 1._real64 , C , 2 )
end program"
BLAS_HAVE_zGEMMT
)
endif()

endif(gemmt)

endif(find_lapack)

if(LAPACK_FOUND)
  return()
endif()


# -- build LAPACK
set(lapack_cmake_args
-DBUILD_SINGLE:BOOL=${BUILD_SINGLE}
-DBUILD_DOUBLE:BOOL=${BUILD_DOUBLE}
-DBUILD_COMPLEX:BOOL=${BUILD_COMPLEX}
-DBUILD_COMPLEX16:BOOL=${BUILD_COMPLEX16}
-DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
-DCMAKE_C_COMPILER:PATH=${CMAKE_C_COMPILER}
-DCMAKE_Fortran_COMPILER:PATH=${CMAKE_Fortran_COMPILER}
-DBUILD_TESTING:BOOL=off
-DCMAKE_BUILD_TYPE:STRING=Release
)

set(LAPACK_INCLUDE_DIRS ${CMAKE_INSTALL_FULL_INCLUDEDIR})
file(MAKE_DIRECTORY ${LAPACK_INCLUDE_DIRS})
if(NOT IS_DIRECTORY ${LAPACK_INCLUDE_DIRS})
  message(FATAL_ERROR "Could not create directory: ${LAPACK_INCLUDE_DIRS}")
endif()

if(BUILD_SHARED_LIBS)
  set(LAPACK_LIBRARIES ${CMAKE_INSTALL_FULL_LIBDIR}/${CMAKE_SHARED_LIBRARY_PREFIX}lapack${CMAKE_SHARED_LIBRARY_SUFFIX})
else()
  set(LAPACK_LIBRARIES ${CMAKE_INSTALL_FULL_LIBDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}lapack${CMAKE_STATIC_LIBRARY_SUFFIX})
endif()

include(${CMAKE_CURRENT_LIST_DIR}/GitSubmodule.cmake)
git_submodule("${PROJECT_SOURCE_DIR}/lapack")

ExternalProject_Add(lapack
SOURCE_DIR ${PROJECT_SOURCE_DIR}/lapack
CMAKE_ARGS ${lapack_cmake_args}
TEST_COMMAND ""
BUILD_BYPRODUCTS ${LAPACK_LIBRARIES}
CONFIGURE_HANDLED_BY_BUILD true
USES_TERMINAL_DOWNLOAD true
USES_TERMINAL_UPDATE true
USES_TERMINAL_PATCH true
USES_TERMINAL_CONFIGURE true
USES_TERMINAL_BUILD true
USES_TERMINAL_INSTALL true
USES_TERMINAL_TEST true
)

add_library(LAPACK::LAPACK INTERFACE IMPORTED GLOBAL)
target_include_directories(LAPACK::LAPACK INTERFACE ${LAPACK_INCLUDE_DIRS})
target_link_libraries(LAPACK::LAPACK INTERFACE ${LAPACK_LIBRARIES})

add_dependencies(LAPACK::LAPACK lapack)
