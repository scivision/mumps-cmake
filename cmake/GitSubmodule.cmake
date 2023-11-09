include_guard()

find_package(Git REQUIRED)

function(git_submodule dir)
# get/update Git submodule directory to CMake, assuming the
# Git submodule directory is a CMake project.

if(NOT EXISTS "${dir}/CMakeLists.txt")
  message(STATUS "Git submodule update ${dir}")

  set(CMAKE_EXECUTE_PROCESS_COMMAND_ECHO STDOUT)

  # --depth 1 or --recommend-shallow had no effect
  execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive -- ${dir}
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    RESULT_VARIABLE _err)

  if(NOT _err EQUAL 0)
    message(FATAL_ERROR "Could not retrieve Git submodule ${dir}.")
  endif()
endif()

endfunction(git_submodule)
