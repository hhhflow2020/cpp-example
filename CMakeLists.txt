cmake_minimum_required(VERSION 3.20)

project(matrix_app VERSION 1.0.0 LANGUAGES CXX)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(ProjectOptions)
include(GNUInstallDirs)

option(APP_WITH_TESTS "Build unit tests" ON)


find_package(fmt CONFIG REQUIRED)

# ---------- libraries ----------
add_library(matrix_core
    src/matrix.cpp
)
target_include_directories(matrix_core
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)
target_compile_features(matrix_core PUBLIC cxx_std_20)
set_target_properties(matrix_core PROPERTIES
    CXX_EXTENSIONS ON
)
target_apply_static_library_defaults(matrix_core)


# ---------- executable ----------
add_executable(matrix_app
    src/main.cpp
)
target_link_libraries(matrix_app PRIVATE
    matrix_core
    fmt::fmt
)
target_compile_features(matrix_app PUBLIC cxx_std_20)
set_target_properties(matrix_app PROPERTIES
    CXX_EXTENSIONS ON
)
target_apply_executable_optimized(matrix_app)


# ---------- install ----------
install(
    TARGETS matrix_core matrix_app
    RUNTIME_DEPENDENCY_SET app_runtime_deps
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

install(RUNTIME_DEPENDENCY_SET app_runtime_deps
    PRE_EXCLUDE_REGEXES
        "api-ms-.*"
        "ext-ms-.*"
    POST_EXCLUDE_REGEXES
        # Windows 系统目录
        ".*system32/.*"
        ".*[Ww][Ii][Nn][Dd][Oo][Ww][Ss]/[Ss][Yy][Ss][Tt][Ee][Mm]32/.*"

        # Linux 系统库目录
        "^/lib/.*"
        "^/lib64/.*"
        "^/usr/lib/.*"
        "^/usr/lib64/.*"

        # macOS 系统库目录
        "^/System/Library/.*"
        "^/usr/lib/.*"
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
)

install(
    DIRECTORY include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

# ---------- pack ----------
set(CPACK_PACKAGE_NAME ${PROJECT_NAME})
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_GENERATOR "TGZ")
include(CPack)


# ---------- tests ----------
if(APP_WITH_TESTS)
    enable_testing()
    find_package(GTest CONFIG REQUIRED)
    include(GoogleTest)

    add_executable(app_tests
        tests/test_matrix.cpp
    )
    target_link_libraries(app_tests PRIVATE
        matrix_core
        GTest::gtest
        GTest::gtest_main
    )
    gtest_discover_tests(app_tests)
endif()