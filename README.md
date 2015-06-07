### cmake scripts for boost compilation

boost-cmake is a CMake script, that allows (now only statically) to compile and install boost libraries from the given directory with boost sources (has to be specified with *Boost_ROOT_DIR*). 

The script is compatible with FindBoost.cmake in cmake distributions.

##### Usage

<PRE>
cmake \
-DBoost_ROOT_DIR=${path_to_unpacked_boost_source_dir} \
-DBoost_COMPONENTS="filesystem;system;mpi;python;chrono;program_options;timer;serialization" \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_INSTALL_PREFIX=${where_to_install} \
${path_to_boost-cmake_dir}
</PRE>

###### Way it works 
- The directories from `${Boost_ROOT_DIR}/libs` that have `src` subdirectory are parsed into a list of libraries. 
- The specified components that match the parsed list of libraries are compiled and installed. 
- The header-only parts are installed separately in the end.

###### Defects:
- No support for dynamic libraries build. It requires solving boost interdependencies.
