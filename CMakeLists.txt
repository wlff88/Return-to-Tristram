cmake_minimum_required(VERSION 3.20)
project(ReturnToTristram LANGUAGES C)
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
include(CTest)

add_library(rtt_runtime src/runtime/runtime_adapter.c)
target_include_directories(rtt_runtime PUBLIC src)

add_library(rtt_assets src/resurrected/assets/assets.c src/resurrected/assets/test_provider.c)
target_include_directories(rtt_assets PUBLIC src)

add_library(rtt_progression src/rtt/progression/progression.c)
target_include_directories(rtt_progression PUBLIC src)

foreach(target rtt_runtime rtt_assets rtt_progression)
    if(MSVC)
        target_compile_options(${target} PRIVATE /W4 /WX)
    else()
        target_compile_options(${target} PRIVATE -Wall -Wextra -Wpedantic -Werror)
    endif()
endforeach()

add_executable(rtt_probe tools/provider_probe.c)
target_link_libraries(rtt_probe PRIVATE rtt_assets rtt_runtime rtt_progression)

if(BUILD_TESTING)
    add_executable(asset_contract_test tests/asset_contract_test.c)
    target_link_libraries(asset_contract_test PRIVATE rtt_assets)
    add_test(NAME asset_contract COMMAND asset_contract_test)

    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/engine/abyss/src/common/RingBuffer.c")
        find_package(Threads REQUIRED)
        add_executable(abyss_ring_buffer_test engine/abyss/tests/RingBufferTest.c
            engine/abyss/src/common/RingBuffer.c engine/abyss/src/util/Mutex.c)
        target_compile_definitions(abyss_ring_buffer_test PRIVATE NO_LOGGING)
        # Upstream tests use assert; keep assertions active in Release too.
        if(MSVC)
            target_compile_options(abyss_ring_buffer_test PRIVATE /UNDEBUG)
        else()
            target_compile_options(abyss_ring_buffer_test PRIVATE -UNDEBUG)
        endif()
        target_link_libraries(abyss_ring_buffer_test PRIVATE Threads::Threads)
        add_test(NAME abyss_ring_buffer COMMAND abyss_ring_buffer_test)
    endif()
endif()

# DevilutionX is intentionally not add_subdirectory()'d here yet.
# It is a separate C++ runtime backend with its own build graph and license boundary.
# Build it from engine/devilutionx using its upstream instructions until the RTT adapter
# has a stable integration point.
