# cmake/ProjectOptions.cmake

include_guard(GLOBAL)

include(CheckIPOSupported)

# ============================================================
# Common Options
# ============================================================

# 基础警告选项
function(target_enable_warnings target)
    target_compile_options(${target} PRIVATE
        -Wall
        -Wextra
        -Wpedantic

        $<$<CXX_COMPILER_ID:GNU>:
            -Wduplicated-cond
            -Wduplicated-branches
            -Wlogical-op
            -Wuseless-cast
        >

        $<$<CXX_COMPILER_ID:Clang>:
            -Wshadow-all
            -Wextra-semi
            -Wheader-hygiene
        >
    )
endfunction()


# Debug 常用选项
function(target_enable_debug_options target)
    target_compile_options(${target} PRIVATE
        $<$<CONFIG:Debug>:
            -O0
            -g3
            -fno-omit-frame-pointer
        >
    )

    target_link_options(${target} PRIVATE
        $<$<CONFIG:Debug>:
            -rdynamic
        >
    )
endfunction()


# Release / MinSizeRel 常用优化选项
function(target_enable_release_options target)
    target_compile_options(${target} PRIVATE
        $<$<CONFIG:Release>:
            -O3
            -DNDEBUG
        >

        $<$<CONFIG:MinSizeRel>:
            -Os
            -DNDEBUG
        >
    )
endfunction()


# 去掉未使用函数、未使用全局数据
#
# 对最终目标 exe / shared library：
#   编译阶段：-ffunction-sections -fdata-sections
#   链接阶段：-Wl,--gc-sections
#
# 对 static library：
#   target_link_options 一般不会产生真正链接效果，
#   静态库应使用 target_enable_static_library_gc_friendly。
function(target_enable_gc_sections target)
    target_compile_options(${target} PRIVATE
        $<$<OR:$<CONFIG:Release>,$<CONFIG:MinSizeRel>>:
            -ffunction-sections
            -fdata-sections
        >
    )

    target_link_options(${target} PRIVATE
        $<$<OR:$<CONFIG:Release>,$<CONFIG:MinSizeRel>>:
            -Wl,--gc-sections
        >
    )
endfunction()


# 减少无用动态库依赖
function(target_enable_as_needed target)
    target_link_options(${target} PRIVATE
        $<$<OR:$<CONFIG:Release>,$<CONFIG:MinSizeRel>>:
            -Wl,--as-needed
        >
    )
endfunction()


# 使用 lld / gold 等链接器
function(target_use_fast_linker target)
    target_link_options(${target} PRIVATE
        $<$<AND:$<CXX_COMPILER_ID:Clang>,$<OR:$<CONFIG:Release>,$<CONFIG:MinSizeRel>>>:
            -fuse-ld=lld
        >

        $<$<AND:$<CXX_COMPILER_ID:GNU>,$<OR:$<CONFIG:Release>,$<CONFIG:MinSizeRel>>>:
            -fuse-ld=gold
        >
    )
endfunction()


# lld 下合并相同代码
function(target_enable_icf target)
    target_link_options(${target} PRIVATE
        $<$<AND:$<CXX_COMPILER_ID:Clang>,$<OR:$<CONFIG:Release>,$<CONFIG:MinSizeRel>>>:
            -Wl,--icf=safe
        >
    )
endfunction()


# 开启 LTO / IPO
function(target_enable_lto target)
    check_ipo_supported(RESULT ipo_supported OUTPUT ipo_error)

    if(ipo_supported)
        set_property(TARGET ${target} PROPERTY
            INTERPROCEDURAL_OPTIMIZATION_RELEASE TRUE
        )

        set_property(TARGET ${target} PROPERTY
            INTERPROCEDURAL_OPTIMIZATION_MINSIZEREL TRUE
        )
    else()
        message(WARNING "IPO/LTO is not supported: ${ipo_error}")
    endif()
endfunction()


# 发布版本 strip
#
# 注意：
# strip 会删除调试符号。
# 如果你需要保留单独的 debug symbol，建议使用 objcopy 单独拆分。
function(target_enable_strip target)
    add_custom_command(TARGET ${target} POST_BUILD
        COMMAND $<$<OR:$<CONFIG:Release>,$<CONFIG:MinSizeRel>>:${CMAKE_STRIP}>
                $<$<OR:$<CONFIG:Release>,$<CONFIG:MinSizeRel>>:$<TARGET_FILE:${target}>>
        COMMAND_EXPAND_LISTS
    )
endfunction()


# 隐藏符号
#
# 常用于：
#   1. shared library 减少导出符号
#   2. 内部 static library 将来被打进 shared library
#
# 不建议默认用于对外发布的 SDK static library。
function(target_enable_hidden_visibility target)
    target_compile_options(${target} PRIVATE
        $<$<CXX_COMPILER_ID:GNU>:
            -fvisibility=hidden
            -fvisibility-inlines-hidden
        >

        $<$<CXX_COMPILER_ID:Clang>:
            -fvisibility=hidden
            -fvisibility-inlines-hidden
        >
    )
endfunction()


# 动态库不允许未定义符号
function(target_enable_no_undefined target)
    target_link_options(${target} PRIVATE
        $<$<OR:$<CXX_COMPILER_ID:GNU>,$<CXX_COMPILER_ID:Clang>>:
            -Wl,--no-undefined
        >
    )
endfunction()


# 动态库隐藏被静态库带入的符号
function(target_exclude_static_lib_symbols target)
    target_link_options(${target} PRIVATE
        $<$<OR:$<CXX_COMPILER_ID:GNU>,$<CXX_COMPILER_ID:Clang>>:
            -Wl,--exclude-libs,ALL
        >
    )
endfunction()


# ASan + UBSan
function(target_enable_sanitizers target)
    target_compile_options(${target} PRIVATE
        $<$<CONFIG:Debug>:
            -fsanitize=address,undefined
            -fno-omit-frame-pointer
        >
    )

    target_link_options(${target} PRIVATE
        $<$<CONFIG:Debug>:
            -fsanitize=address,undefined
        >
    )
endfunction()


# 输出 gc-sections 删除日志，排查用
function(target_enable_gc_sections_report target)
    target_link_options(${target} PRIVATE
        $<$<OR:$<CONFIG:Release>,$<CONFIG:MinSizeRel>>:
            -Wl,--print-gc-sections
        >
    )
endfunction()


# 开启 PIC
#
# 常用于：
#   static library 将来被链接进 shared library
function(target_enable_pic target)
    set_property(TARGET ${target} PROPERTY
        POSITION_INDEPENDENT_CODE ON
    )
endfunction()


# ============================================================
# Static Library Options
# ============================================================

# 静态库编译成 gc-sections 友好的形式
#
# 静态库本身不会真正执行链接裁剪，
# 这里只是让每个函数/数据进入独立 section，
# 方便最终 exe / shared library 使用 --gc-sections 删除无用代码。
function(target_enable_static_library_gc_friendly target)
    target_compile_options(${target} PRIVATE
        $<$<OR:$<CONFIG:Release>,$<CONFIG:MinSizeRel>>:
            -ffunction-sections
            -fdata-sections
        >
    )
endfunction()


# 静态库常用默认配置
#
# 适用于：
#   内部普通 static library，最终被 exe 或 shared library 使用。
function(target_apply_static_library_defaults target)
    target_enable_warnings(${target})
    target_enable_debug_options(${target})
    target_enable_release_options(${target})
    target_enable_static_library_gc_friendly(${target})
endfunction()


# 静态库将来会被打进 shared library
#
# 适用于：
#   add_library(core STATIC ...)
#   add_library(mylib SHARED ...)
#   target_link_libraries(mylib PRIVATE core)
function(target_apply_static_library_for_shared target)
    target_apply_static_library_defaults(${target})
    target_enable_pic(${target})
    target_enable_hidden_visibility(${target})
endfunction()


# 静态库作为 SDK 发布给别人链接
#
# 注意：
#   SDK static library 通常不建议默认开启 -fvisibility=hidden，
#   否则使用方最终链接时可能遇到符号不可见、插件注册、工厂函数等问题。
function(target_apply_static_library_sdk_defaults target)
    target_enable_warnings(${target})
    target_enable_debug_options(${target})
    target_enable_release_options(${target})
    target_enable_static_library_gc_friendly(${target})
endfunction()


# ============================================================
# Executable Options
# ============================================================

# 可执行文件常用默认配置
function(target_apply_executable_defaults target)
    target_enable_warnings(${target})
    target_enable_debug_options(${target})
    target_enable_release_options(${target})
    target_enable_gc_sections(${target})
    target_enable_as_needed(${target})
endfunction()


# 更激进的可执行文件配置
function(target_apply_executable_optimized target)
    target_apply_executable_defaults(${target})
    target_use_fast_linker(${target})
    target_enable_icf(${target})
    target_enable_lto(${target})
endfunction()


# ============================================================
# Shared Library Options
# ============================================================

# 动态库常用默认配置
function(target_apply_shared_library_defaults target)
    target_enable_warnings(${target})
    target_enable_debug_options(${target})
    target_enable_release_options(${target})
    target_enable_gc_sections(${target})
    target_enable_hidden_visibility(${target})
    target_enable_no_undefined(${target})
    target_exclude_static_lib_symbols(${target})
endfunction()


# 更激进的动态库配置
function(target_apply_shared_library_optimized target)
    target_apply_shared_library_defaults(${target})
    target_use_fast_linker(${target})
    target_enable_icf(${target})
    target_enable_lto(${target})
endfunction()