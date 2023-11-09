option(gemmt "GEMMT is recommended in User Manual if available" ON)

option(parallel "parallel (use MPI)" ON)

option(intsize64 "use 64-bit integers in C and Fortran")

option(scotch "use Scotch orderings ")

option(parmetis "use parallel METIS ordering")
option(metis "use sequential METIS ordering")
if(parmetis AND NOT parallel)
  message(FATAL_ERROR "parmetis requires parallel=on")
endif()

option(openmp "use OpenMP")

option(matlab "Matlab interface" OFF)
option(octave "GNU Octave interface" OFF)
if((matlab OR octave) AND parallel)
  message(FATAL_ERROR "Matlab / Octave requires parallel=off")
endif()

option(find_lapack "find LAPACK" on)
option(find_scalapack "find ScaLAPACK" on)
option(find_static "Find static libraries for Lapack and Scalapack (default shared then static search)")

option(BUILD_SHARED_LIBS "Build shared libraries")

set(CMAKE_POSITION_INDEPENDENT_CODE ON)

option(BUILD_SINGLE "Build single precision float32 real" ON)
option(BUILD_DOUBLE "Build double precision float64 real" ON)
option(BUILD_COMPLEX "Build single precision complex")
option(BUILD_COMPLEX16 "Build double precision complex")

# --- other options

set_property(DIRECTORY PROPERTY EP_UPDATE_DISCONNECTED true)
set(FETCHCONTENT_UPDATES_DISCONNECTED true)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT AND PROJECT_IS_TOP_LEVEL)
  set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/local" CACHE PATH "default install path" FORCE)
endif()
