# #%L
# Bio-Formats C++ libraries (cmake build infrastructure)
# %%
# Copyright © 2006 - 2015 Open Microscopy Environment:
#   - Massachusetts Institute of Technology
#   - National Institutes of Health
#   - University of Dundee
#   - Board of Regents of the University of Wisconsin-Madison
#   - Glencoe Software, Inc.
# %%
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# The views and conclusions contained in the software and documentation are
# those of the authors and should not be interpreted as representing official
# policies, either expressed or implied, of any organization.
# #L%

enable_testing()
option(test "Enable unit tests (requires gtest)" ON)
set(BUILD_TESTS ${test})
set(EXTENDED_TESTS ${extended-tests})
set(GTEST_SRC_DIR "/usr/src/googletest/googletest/")

# Unit tests
find_package(Threads REQUIRED)

if(BUILD_TESTS)
  if(EXISTS ${GTEST_SRC_DIR})
    ## Upstream recommends against using precompiled libraries and
    ## installation of gtest.  Instead, each project should compile
    ## gtest itself from local sources.  See issue #42.
    include(ExternalProject)
    message(STATUS "Using googletest at ${GTEST_SRC_DIR} as external project")
    ExternalProject_Add(GTest
      SOURCE_DIR ${GTEST_SRC_DIR}
      PREFIX "${CMAKE_CURRENT_BINARY_DIR}/GTest"
      CONFIGURE_COMMAND ""
      BUILD_COMMAND ""
      INSTALL_COMMAND ""
      TEST_COMMAND ""
      )
    ExternalProject_Get_Property(GTest SOURCE_DIR BINARY_DIR)

    execute_process(COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" ${SOURCE_DIR}
      RESULT_VARIABLE gtest_cmake_result
      WORKING_DIRECTORY ${BINARY_DIR})
    if(gtest_cmake_result)
      message(FATAL_ERROR "CMake of GTest failed: ${gtest_cmake_result}")
    endif()

    execute_process(COMMAND ${CMAKE_COMMAND} --build .
      RESULT_VARIABLE gtest_cmake_result
      WORKING_DIRECTORY ${BINARY_DIR})
    if(gtest_cmake_result)
      message(FATAL_ERROR "Build of GTest failed: ${gtest_cmake_result}")
    endif()

    ## This adds the gtest and gtest_main targets...
    add_subdirectory(${SOURCE_DIR} ${BINARY_DIR})
    ## but the project expects GTest::GTest which is what would be
    ## imported if we were using find_package(GTest)
    add_library(GTest::GTest ALIAS gtest)
  else()
    find_package(GTest)
    if(NOT GTEST_FOUND)
      message(WARNING "GTest not found; tests disabled")
      set(BUILD_TESTS OFF)
    endif()
  endif()
endif()
