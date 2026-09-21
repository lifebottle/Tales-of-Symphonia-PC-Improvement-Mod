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
    src/battle_patches.cpp
    src/patch_options.cpp
    src/patch_runtime.cpp
    src/patch_host.cpp
    src/game_patches.cpp
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

add_executable(tos-ct-converter WIN32 tools/patch_gui.cpp)
target_link_libraries(tos-ct-converter PRIVATE ct_import comctl32 comdlg32 ole32 uuid)
target_compile_definitions(tos-ct-converter PRIVATE WIN32_LEAN_AND_MEAN NOMINMAX)
if(MINGW)
    target_link_options(tos-ct-converter PRIVATE -municode -static "$<$<CONFIG:Release>:-s>")
endif()
add_custom_target(patch_packages ALL
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/patches ${CMAKE_CURRENT_BINARY_DIR}/patches)
install(TARGETS d3d9 tos-ct-converter tos-patch RUNTIME DESTINATION . LIBRARY DESTINATION .)
install(DIRECTORY patches DESTINATION . PATTERN "*.json" EXCLUDE)
install(FILES third_party/PATCH_DEPENDENCIES.md DESTINATION licenses)
foreach(dep asmjit asmtk pugixml)
    install(FILES third_party/${dep}/LICENSE.md DESTINATION licenses/${dep})
endforeach()
foreach(dep zydis tomlplusplus)
    install(FILES third_party/${dep}/LICENSE DESTINATION licenses/${dep})
endforeach()
install(FILES third_party/zydis/dependencies/zycore/LICENSE DESTINATION licenses/zycore)
install(FILES docs/PATCH_AUTHORING.md DESTINATION docs)
install(FILES tools/PORTABLE_README.txt DESTINATION . RENAME README.txt)
set(CPACK_GENERATOR ZIP)
set(CPACK_PACKAGE_NAME TOS-Patch-Tools)
set(CPACK_PACKAGE_VERSION 2.0.2)
include(CPack)

include(CTest)
if(BUILD_TESTING AND MINGW)
    foreach(name battle_patches lloyd_super_chain spell_slots spell_queue ct_converter patch_framework)
        add_executable(${name}_test tests/patches/${name}_windows_test.cpp src/patch_runtime.cpp src/patch_options.cpp)
        target_link_libraries(${name}_test PRIVATE patch_compiler)
        target_compile_definitions(${name}_test PRIVATE WIN32_LEAN_AND_MEAN NOMINMAX)
        target_compile_options(${name}_test PRIVATE -UNDEBUG)
        target_link_options(${name}_test PRIVATE -static)
        if(name STREQUAL "patch_framework")
            target_sources(${name}_test PRIVATE src/patch_host.cpp)
        endif()
    endforeach()
endif()
