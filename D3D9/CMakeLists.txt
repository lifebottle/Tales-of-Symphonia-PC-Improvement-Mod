cmake_minimum_required(VERSION 3.15)
project(TOSImprovementMod LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Build as a shared library (DLL)
add_library(d3d9 SHARED
    src/dllmain.cpp
    src/d3d9_proxy.cpp
    src/d3d9ex_proxy.cpp
    src/device_proxy.cpp
    src/d3dx9_hook.cpp
    src/texture_manager.cpp
    src/dds_loader.cpp
    src/battle_patches.cpp
    src/patch_definitions.cpp
    src/patch_runtime.cpp
    src/patch_host.cpp
    src/game_patches.cpp
    src/fast_forward.cpp
    src/fast_forward_overlay.cpp
    d3d9.def
)

target_include_directories(d3d9 PRIVATE src)

# DO NOT link against d3d9.lib — it creates a circular import dependency
# since our output IS d3d9.dll. All real d3d9 functions are loaded at runtime
# via LoadLibrary/GetProcAddress. COM interfaces are header-only (pure virtual).

set_target_properties(d3d9 PROPERTIES
    OUTPUT_NAME "d3d9"
    PREFIX ""
    SUFFIX ".dll"
)

# MSVC settings
if(MSVC)
    target_compile_definitions(d3d9 PRIVATE
        WIN32_LEAN_AND_MEAN
        NOMINMAX
        _CRT_SECURE_NO_WARNINGS
    )
    # Use static runtime for maximum portability
    set_property(TARGET d3d9 PROPERTY
        MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>"
    )
endif()

# MinGW cross-compilation support (primary target: build on Linux for Windows/Proton)
if(MINGW)
    target_compile_definitions(d3d9 PRIVATE
        WIN32_LEAN_AND_MEAN
        NOMINMAX
        _CRT_SECURE_NO_WARNINGS
    )
    target_compile_options(d3d9 PRIVATE -Os -fno-rtti)
    target_link_options(d3d9 PRIVATE
        -static-libgcc -static-libstdc++
        -Wl,--enable-stdcall-fixup
        -Wl,-Bstatic,--whole-archive -lwinpthread -Wl,--no-whole-archive,-Bdynamic
        -Wl,--gc-sections -s
    )
endif()

# Ready-to-copy release layout. Assembly/Python are only needed to assemble native hooks.
add_custom_command(TARGET d3d9 POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory "$<TARGET_FILE_DIR:d3d9>/patches"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_CURRENT_SOURCE_DIR}/patches/battle-enhancements.json"
        "$<TARGET_FILE_DIR:d3d9>/patches/battle-enhancements.json"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_CURRENT_SOURCE_DIR}/patches/lloyd-super-chain.json"
        "$<TARGET_FILE_DIR:d3d9>/patches/lloyd-super-chain.json")
