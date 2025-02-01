cmake_minimum_required(VERSION 3.30)
project(waveguide CUDA)

find_program(GNUPLOT_EXECUTABLE gnuplot)
if (NOT GNUPLOT_EXECUTABLE)
    message(WARNING "Gnuplot not found - plotting functionality will not work!")
else ()
    string(REPLACE "\\" "/" GNUPLOT_EXECUTABLE_PATH "${GNUPLOT_EXECUTABLE}")
    add_compile_definitions(GNUPLOT_EXECUTABLE="${GNUPLOT_EXECUTABLE_PATH}")
endif ()

set(CMAKE_CUDA_STANDARD 20)

file(GLOB BASE_SOURCES "src/wg*.cu")
add_executable(waveguide ${BASE_SOURCES})

set_target_properties(waveguide PROPERTIES
        CUDA_SEPARABLE_COMPILATION ON)

if (MSVC)
    set_target_properties(waveguide PROPERTIES
            LINK_FLAGS "/NODEFAULTLIB:LIBCMT"
    )
endif ()