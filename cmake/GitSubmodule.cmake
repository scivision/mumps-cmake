# else it's an offline archive
if(IS_DIRECTORY ${PROJECT_SOURCE_DIR}/.git)
  find_package(Git REQUIRED)
endif()

function(git_submodule submod_dir)
# get/update Git submodule directory to CMake, assuming the
# Git submodule directory is a CMake project.

# EXISTS, do not use IS_DIRECTORY as in submodule .git is a file not a directory
if(NOT EXISTS ${PROJECT_SOURCE_DIR}/.git)
  message(DEBUG "${PROJECT_SOURCE_DIR} is not a Git repository, skipping submodule ${submod_dir}")
  return()
endif()

if(EXISTS ${submod_dir}/CMakeLists.txt)
  return()
endif()

execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive -- ${submod_dir}
WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
RESULT_VARIABLE err)

if(NOT err EQUAL 0)
  message(FATAL_ERROR "${submod_dir} Git submodule failed to retrieve.")
endif()

endfunction()


function(report_submodule submod_dir)
  # get the following information for the Git submodule
  # git remote -v
  # git status --porcelain
  # git commit hash

  if(NOT EXISTS ${submod_dir}/.git)
    message(VERBOSE "${submod_dir} is not a Git submodule, skipping}")
    return()
  endif()

  set(git_remote "origin")
  # Git default remote name

  execute_process(COMMAND ${GIT_EXECUTABLE} -C ${submod_dir} remote get-url ${git_remote}
  OUTPUT_VARIABLE r
  OUTPUT_STRIP_TRAILING_WHITESPACE
  RESULT_VARIABLE ret
  )

  if(NOT ret EQUAL 0)
    message(STATUS "Git remote failed for ${submod_dir}")
    return()
  endif()

  if(r MATCHES "@")
    # remove token from remote URL
    string(REGEX REPLACE "://[^@]+@" "://" r "${r}")
  endif()

  execute_process(COMMAND ${GIT_EXECUTABLE} -C ${submod_dir} status --porcelain
  OUTPUT_VARIABLE p
  OUTPUT_STRIP_TRAILING_WHITESPACE
  RESULT_VARIABLE ret
  )

  if(NOT ret EQUAL 0)
    message(STATUS "Git status failed for ${submod_dir}")
    return()
  endif()

  string(LENGTH "${p}" p_len)
  if(p_len EQUAL 0)
    set(porcelain "clean")
  else()
    set(porcelain "dirty")
  endif()

  execute_process(COMMAND ${GIT_EXECUTABLE} -C ${submod_dir} rev-parse --short HEAD
  OUTPUT_VARIABLE h
  OUTPUT_STRIP_TRAILING_WHITESPACE
  RESULT_VARIABLE ret
  )

  if(NOT ret EQUAL 0)
    message(STATUS "Git rev-parse failed for ${submod_dir}")
    return()
  endif()

  get_filename_component(name ${submod_dir} NAME)

  message(STATUS "${name} remote: ${r} ${porcelain} ${h}")

endfunction()
