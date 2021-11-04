cmake_minimum_required(VERSION 3.13)

project(redis-sw)

set(CMAKE_C_COMPILER gcc)
set(CMAKE_CXX_COMPILER g++)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

find_path(HIREDIS_HEADER hiredis)

find_library(HIREDIS_LIB hiredis)

find_path(REDIS_PLUS_PLUS_HEADER sw)

find_library(REDIS_PLUS_PLUS_LIB redis++)

add_executable(redis-sw main.cpp)

target_link_libraries(redis-sw Threads::Threads ${HIREDIS_LIB} ${REDIS_PLUS_PLUS_LIB} pthread dl :uSockets.a ssl crypto z)

target_include_directories(redis-sw PUBLIC ${HIREDIS_HEADER} ${REDIS_PLUS_PLUS_HEADER})