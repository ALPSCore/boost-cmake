MACRO(getsubdirs result curdir)
  FILE(GLOB children RELATIVE ${curdir} ${curdir}/*)
  SET(dirlist "")
  FOREACH(child ${children})
    IF(IS_DIRECTORY ${curdir}/${child})
        SET(dirlist ${dirlist} ${child})
    ENDIF()
  ENDFOREACH()
  SET(${result} ${dirlist})
ENDMACRO()

# filter out elements of list that match `pattern` 
macro(filterlist LIST pattern output)
foreach(item ${LIST})
    string(REGEX MATCH "/${pattern}/" regex_result ${item})
    if(NOT regex_result)
        list(APPEND output_list ${item})
    endif(NOT regex_result)
endforeach(item ${LIST})
set (${output} ${output_list})
endmacro()
