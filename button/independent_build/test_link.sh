#!/bin/bash

# 独立链接测试脚本
# 目的：验证我们收集的.a文件和链接脚本是否足够进行独立编译

LLVM_COMPILER="/Users/zhangzhiyang/.espressif/tools/esp-clang/esp-18.1.2_20240912/esp-clang/bin/clang"
LINKER="xtensa-esp32-elf-clang-ld"
TARGET_ARCH="--target=xtensa-esp-elf -mcpu=esp32"

# 项目文件
PROJECT_ROOT=".."
LLGO_OBJ="$PROJECT_ROOT/main/llgo.o"

# 独立构建资源
LIBS_DIR="./libs"
LINKER_SCRIPTS_DIR="./linker_scripts"

echo "=== 独立链接测试 ==="
echo "LLVM编译器: $LLVM_COMPILER"
echo "LLGO目标文件: $LLGO_OBJ"
echo "静态库数量: $(ls -1 $LIBS_DIR/*.a | wc -l)"
echo "链接脚本数量: $(ls -1 $LINKER_SCRIPTS_DIR/*.ld | wc -l)"

# 构建链接命令
echo ""
echo "=== 构建链接参数 ==="

# 收集所有.a文件
LIBRARY_FILES=$(find $LIBS_DIR -name "*.a" | sort | tr '\n' ' ')
echo "库文件总数: $(echo $LIBRARY_FILES | wc -w)"

# 收集链接脚本
LINKER_SCRIPT_FLAGS=""
for ld_file in $LINKER_SCRIPTS_DIR/*.ld; do
    if [[ $(basename "$ld_file") != "memory.ld" && $(basename "$ld_file") != "sections.ld" ]]; then
        LINKER_SCRIPT_FLAGS="$LINKER_SCRIPT_FLAGS -T $(basename "$ld_file")"
    fi
done

echo "链接脚本参数: $LINKER_SCRIPT_FLAGS"

# 模拟链接命令 (不实际执行)
LINK_CMD="$LLVM_COMPILER $TARGET_ARCH \\
    --ld-path=$LINKER \\
    -z noexecstack \\
    -Wl,--cref \\
    -Wl,--defsym=IDF_TARGET_ESP32=0 \\
    -Wl,--Map=independent_button.map \\
    -Wl,--no-warn-rwx-segments \\
    -Wl,--orphan-handling=warn \\
    -fno-rtti -fno-lto \\
    -Wl,--gc-sections \\
    -Wl,--warn-common \\
    $LINKER_SCRIPT_FLAGS \\
    -T memory.ld \\
    -T sections.ld \\
    $LLGO_OBJ \\
    $LIBRARY_FILES \\
    -o independent_button.elf"

echo ""
echo "=== 生成的链接命令 ==="
echo "$LINK_CMD"

echo ""
echo "=== 准备工作完成 ==="
echo "✅ 静态库收集完成: $(ls -1 $LIBS_DIR/*.a | wc -l) 个"
echo "✅ 链接脚本收集完成: $(ls -1 $LINKER_SCRIPTS_DIR/*.ld | wc -l) 个"
echo "✅ 独立链接命令已生成"
echo ""
echo "下一步: 在不依赖ESP-IDF环境的情况下尝试独立链接"