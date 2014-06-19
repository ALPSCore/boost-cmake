# 
# Cmake boost compilation script
# (C) A. Antipov, 2014 
# 

cmake_minimum_required (VERSION 2.8)

# define Boost_ROOT_DIR - path to Boost sources
if (NOT DEFINED Boost_ROOT_DIR)
    message(FATAL_ERROR "Boost_ROOT_DIR unset. Please set Boost_ROOT_DIR to the location of boost sources")
else()
    message(STATUS "Compiling boost from ${Boost_ROOT_DIR}.")
endif()

# compile using c++ compiler only
project(boost-cmake CXX)

# add modules from cmake directory
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
# add common macros
include(CommonMacros)

# get the list of boost libraries by checking existence of lib/#/src subdirectory
getsubdirs(boost_libdirs ${Boost_ROOT_DIR}/libs)
foreach(boost_dir ${boost_libdirs})
    if (EXISTS ${Boost_ROOT_DIR}/libs/${boost_dir}/src)
        list(APPEND boost_all_libs ${boost_dir})
    endif()
endforeach()
# hacks // FIXME 
list(REMOVE_ITEM boost_all_libs smart_ptr thread graph math random)
#list(REMOVE_ITEM boost_all_libs config detail mpl preprocessor tuple utility type_traits iterator)

# if no components required - build everything from boost_standard_components (somewhat biased list)
list(APPEND boost_standard_components date_time chrono filesystem mpi system serialization regex program_options exception atomic)
list(LENGTH Boost_COMPONENTS comp_len)
if (${comp_len} EQUAL 0) 
    set(Boost_COMPONENTS ${boost_standard_components})
endif()

# check for MPI
list(FIND Boost_COMPONENTS mpi has_no_mpi)
if (NOT ${has_no_mpi} EQUAL -1) # e.g. if we have mpi component 
    set(BOOST_HAS_MPI true)
    find_package(MPI REQUIRED)
    add_definitions(${MPI_CXX_COMPILE_FLAGS}  ${MPI_C_COMPILE_FLAGS})
    include_directories(${MPI_CXX_INCLUDE_PATH})
    link_libraries(${MPI_CXX_LIBRARIES})
else()
    list(APPEND boost_lib_glob_exclude mpi)
    set(BOOST_HAS_MPI false)
endif()

# check for Python
list(FIND Boost_COMPONENTS python has_python)
if (NOT ${has_no_python} EQUAL -1) # e.g. if we have python component
    set(BOOST_HAS_PYTHON true)
    find_package(PythonLibs REQUIRED)
    include_directories(${PYTHON_INCLUDE_DIRS})
    link_libraries(${PYTHON_LIBRARIES})
else()
    list(APPEND boost_lib_glob_exclude python)
    set(BOOST_HAS_PYTHON false)
endif()

# include headers from "boost" subdirectory
include_directories(${Boost_ROOT_DIR})

# build boost libraries and install them along with corresponding headers
foreach(boost_lib ${Boost_COMPONENTS})
    list(FIND boost_all_libs ${boost_lib} has_boost_lib)
    # check if such component exists
    if (${has_boost_lib} EQUAL -1) 
        message(FATAL_ERROR "Boost : Unknown lib ${boost_lib}")
    else()
        message(STATUS "Building ${boost_lib}")
        set (boost_lib_dir ${Boost_ROOT_DIR}/libs/${boost_lib}/src)
        file(GLOB_RECURSE SOURCES "${boost_lib_dir}/*.cpp")

        # filter out python if not defined
        if (NOT BOOST_HAS_PYTHON AND ${boost_lib} STREQUAL mpi)
            filterlist("${SOURCES}" python filtered)  
            set(SOURCES ${filtered})
        endif()
        # filter out mpi if not defined
        if (NOT BOOST_HAS_MPI)
            filterlist("${SOURCES}" mpi filtered)  
            set(${SOURCES} ${filtered})
        endif()
        # compile component
        add_library(boost_${boost_lib} STATIC ${SOURCES})
        # install component
        install(TARGETS boost_${boost_lib} DESTINATION lib)
        # install corresponding headers
        install(DIRECTORY ${Boost_ROOT_DIR}/boost/${boost_lib} DESTINATION include/boost FILES_MATCHING PATTERN "*.hpp" PATTERN "*.ipp" PATTERN "*.h")
    endif (${has_boost_lib} EQUAL -1) 
endforeach(boost_lib ${Boost_COMPONENTS})

# install header-only parts (exclude already installed component headers)

foreach(boost_lib ${boost_all_libs})
    list(APPEND all_header_excludes ${all_headers_excludes} PATTERN ${boost_lib} EXCLUDE) 
endforeach(boost_lib ${boost_all_libs})

install(
    DIRECTORY ${Boost_ROOT_DIR}/boost
    DESTINATION include 
    FILES_MATCHING PATTERN "*.hpp" PATTERN "*.ipp" PATTERN "*.h"
    ${all_header_excludes} # exclude everything from exclude 
    )

