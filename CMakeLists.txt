cmake_minimum_required(VERSION 3.31)
project(TOSImprovementMod LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
if(MSVC)
    add_compile_options(/utf-8)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endif()

include(patch_compiler.cmake)
if(NOT WIN32)
    return()
endif()

# Build as a shared library (DLL)
add_library(d3d9 SHARED
    src/dllmain.cpp
    src/d3d9_proxy.cpp
    src/d3d9ex_proxy.cpp
    src/device_proxy.cpp
    src/d3dx9_hook.cpp
    src/texture_manager.cpp
    src/dds_loader.cpp
    src/patch_loader.cpp
    src/patch_options.cpp
    src/patch_runtime.cpp
    src/patch_host.cpp
    src/archive_loader.cpp
    src/fast_forward.cpp
    src/fast_forward_overlay.cpp
    d3d9.def
)

target_include_directories(d3d9 PRIVATE src)
target_link_libraries(d3d9 PRIVATE patch_compiler)

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

install(TARGETS d3d9 RUNTIME DESTINATION . LIBRARY DESTINATION .)
install(DIRECTORY patches/ DESTINATION mods/asm PATTERN "*.json" EXCLUDE)
install(FILES third_party/PATCH_DEPENDENCIES.md DESTINATION licenses)
foreach(dep asmjit asmtk)
    install(FILES third_party/${dep}/LICENSE.md DESTINATION licenses/${dep})
endforeach()
foreach(dep zydis tomlplusplus)
    install(FILES third_party/${dep}/LICENSE DESTINATION licenses/${dep})
endforeach()
install(FILES third_party/zydis/dependencies/zycore/LICENSE DESTINATION licenses/zycore)
install(FILES README.md DESTINATION .)
set(CPACK_GENERATOR ZIP)
set(CPACK_PACKAGE_NAME TOS-Improvement-Mod)
set(CPACK_PACKAGE_VERSION 0.0.0-0)
include(CPack)
