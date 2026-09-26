cmake_minimum_required(VERSION 3.22.1)
project(zionpty)

add_library(zionpty SHARED zion_pty.c)
target_compile_features(zionpty PRIVATE c_std_11)
target_link_libraries(zionpty log)
