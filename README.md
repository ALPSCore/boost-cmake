### cmake scripts for boost compilation

boost-cmake is a CMake script, that allows (now only statically) to compile and install boost libraries from the given directory with boost sources (has to be specified with *Boost_ROOT_DIR*). 

The script is compatible with FindBoost.cmake in cmake distributions.

##### Usage
``cmake -DBoost_ROOT_DIR=_path_to_boost_source_ -DBoost_COMPONENTS=filesystem system mpi ... _path_to_boost-cmake_dir``

###### Way it works 
- The directories from `${Boost_ROOT_DIR}/libs` that have `src` subdirectory are parsed into a list of libraries. 
- The specified components that match the parsed list of libraries are compiled and installed. 
- The header-only parts are installed separately in the end.

###### Defects:
- No support for dynamic libraries build. It requires solving boost interdependencies.
