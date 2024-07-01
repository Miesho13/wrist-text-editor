# Minimum CMake version required
cmake_minimum_required(VERSION 3.10)

# Project name and version
project(wrist)

# Specify the C standard
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED True)

# target_compile_options(${PROJECT_NAME} PRIVATE --Wall --Wextra --Werror -g)

# Add the executable
add_executable(${PROJECT_NAME} src/main.c)
