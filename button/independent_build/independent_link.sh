#!/bin/bash

# 完全独立的ESP32固件链接脚本
# 目标：不依赖ESP-IDF环境，使用收集的依赖文件独立生成固件

set -e  # 遇到错误立即退出

echo "🚀 开始独立链接流程..."

# 配置路径
LLVM_COMPILER="/Users/zhangzhiyang/.espressif/tools/esp-clang/esp-18.1.2_20240912/esp-clang/bin/clang"
LINKER="xtensa-esp32-elf-clang-ld"
TARGET_ARCH="--target=xtensa-esp-elf -mcpu=esp32"

# 项目文件
PROJECT_ROOT=".."
LLGO_OBJ="$PROJECT_ROOT/main/complete_init_llgo.o"

# 独立构建资源
LIBS_DIR="./libs"
LINKER_SCRIPTS_DIR="./linker_scripts"

# 输出文件
OUTPUT_ELF="independent_button.elf"
OUTPUT_BIN="independent_button.bin"
OUTPUT_MAP="independent_button.map"

echo "📋 验证输入文件..."

# 验证LLGO目标文件存在
if [[ ! -f "$LLGO_OBJ" ]]; then
    echo "❌ 错误: LLGO目标文件不存在: $LLGO_OBJ"
    exit 1
fi
echo "✅ LLGO目标文件: $LLGO_OBJ"

# 验证LLVM编译器存在
if [[ ! -f "$LLVM_COMPILER" ]]; then
    echo "❌ 错误: LLVM编译器不存在: $LLVM_COMPILER"
    exit 1
fi
echo "✅ LLVM编译器: $LLVM_COMPILER"

# 统计资源
LIB_COUNT=$(find $LIBS_DIR -name "*.a" | wc -l)
LD_COUNT=$(find $LINKER_SCRIPTS_DIR -name "*.ld" | wc -l)
echo "✅ 静态库数量: $LIB_COUNT"
echo "✅ 链接脚本数量: $LD_COUNT"

echo ""
echo "🔗 构建链接命令..."

# 收集所有.a文件 - 按依赖顺序排列
LIBRARY_FILES=""

# 核心系统库 (按依赖顺序)
CORE_LIBS=(
    "libmain.a"                    # 用户主程序 (如果存在)
    "libesp_system.a"              # ESP系统核心
    "libfreertos.a"                # FreeRTOS操作系统
    "libesp_hw_support.a"          # 硬件支持
    "libhal.a"                     # 硬件抽象层
    "libsoc.a"                     # 芯片级支持
    "libesp_rom.a"                 # ROM函数
    "libnewlib.a"                  # C标准库
    "liblog.a"                     # 日志系统
    "libheap.a"                    # 内存管理
    "libesp_common.a"              # 通用功能
    "libxtensa.a"                  # Xtensa架构支持
    "libxt_hal.a"                  # Xtensa硬件抽象
)

# WiFi和网络库
WIFI_LIBS=(
    "libcore.a"                    # WiFi核心
    "libnet80211.a"                # 802.11协议栈
    "libpp.a"                      # 物理层协议
    "libespnow.a"                  # ESP-NOW
    "libsmartconfig.a"             # 智能配置
    "libmesh.a"                    # Mesh网络
    "libwapi.a"                    # WAPI安全
    "libesp_wifi.a"                # WiFi驱动
    "libesp_netif.a"               # 网络接口
    "liblwip.a"                    # TCP/IP协议栈
    "libwpa_supplicant.a"          # WPA认证
)

# 驱动库
DRIVER_LIBS=(
    "libesp_driver_gpio.a"         # GPIO驱动
    "libesp_driver_uart.a"         # UART驱动
    "libesp_driver_gptimer.a"      # 定时器驱动
    "libdriver.a"                  # 通用驱动
)

# 其他功能库
OTHER_LIBS=(
    "libesp_timer.a"               # ESP定时器
    "libesp_event.a"               # 事件系统
    "libesp_ringbuf.a"             # 环形缓冲区
    "libnvs_flash.a"               # NVS存储
    "libspi_flash.a"               # SPI Flash
    "libesp_partition.a"           # 分区管理
    "libbootloader_support.a"      # 引导加载支持
    "libesp_app_format.a"          # 应用格式
    "libefuse.a"                   # eFuse
    "libesp_mm.a"                  # 内存管理
    "libesp_phy.a"                 # 物理层
    "libphy.a"                     # 物理层硬件
    "librtc.a"                     # RTC
    "libvfs.a"                     # 虚拟文件系统
    "libpthread.a"                 # POSIX线程
    "libcxx.a"                     # C++支持
    "libesp_gdbstub.a"             # GDB调试支持
    "libesp_coex.a"                # 共存协议
    "libxt_hal.a"                  # Xtensa硬件抽象层
)

# MbedTLS 库
MBEDTLS_LIBS=(
    "libmbedtls.a"                 # MbedTLS主库
    "libmbedcrypto.a"              # 加密库
    "libmbedx509.a"                # X.509证书
    "libeverest.a"                 # Everest椭圆曲线
    "libp256m.a"                   # P256M椭圆曲线
)

# 按顺序添加库文件 - 使用ESP-IDF的三次链接策略来解决循环依赖
add_libs_if_exist() {
    local libs=("$@")
    for lib in "${libs[@]}"; do
        if [[ -f "$LIBS_DIR/$lib" ]]; then
            LIBRARY_FILES="$LIBRARY_FILES $LIBS_DIR/$lib"
        fi
    done
}

# 第一轮：添加核心依赖库
add_libs_if_exist "${CORE_LIBS[@]}"
add_libs_if_exist "${WIFI_LIBS[@]}"
add_libs_if_exist "${DRIVER_LIBS[@]}"
add_libs_if_exist "${OTHER_LIBS[@]}"
add_libs_if_exist "${MBEDTLS_LIBS[@]}"

# 添加剩余的库文件
for lib in $LIBS_DIR/*.a; do
    if [[ ! "$LIBRARY_FILES" =~ "$lib" ]]; then
        LIBRARY_FILES="$LIBRARY_FILES $lib"
    fi
done

# 第二轮：重复添加核心库来解决循环依赖（模仿ESP-IDF链接策略）
add_libs_if_exist "${CORE_LIBS[@]}"
add_libs_if_exist "${WIFI_LIBS[@]}"
add_libs_if_exist "${DRIVER_LIBS[@]}"
add_libs_if_exist "${OTHER_LIBS[@]}"
add_libs_if_exist "${MBEDTLS_LIBS[@]}"

# 第三轮：再次添加核心系统库来解决复杂的符号依赖
add_libs_if_exist "${CORE_LIBS[@]}"
add_libs_if_exist "${MBEDTLS_LIBS[@]}"

echo "📝 库文件总数: $(echo $LIBRARY_FILES | wc -w)"

# 构建链接脚本参数
LINKER_SCRIPT_FLAGS=""
for ld_file in $LINKER_SCRIPTS_DIR/esp32.*.ld; do
    if [[ -f "$ld_file" ]]; then
        LINKER_SCRIPT_FLAGS="$LINKER_SCRIPT_FLAGS -T $(basename "$ld_file")"
    fi
done

echo "🔧 链接脚本参数: $LINKER_SCRIPT_FLAGS"

# 准备链接脚本路径参数 (使用绝对路径)
LINKER_SCRIPT_PATH_FLAGS=""
for ld_file in $LINKER_SCRIPTS_DIR/esp32.*.ld; do
    if [[ -f "$ld_file" ]]; then
        LINKER_SCRIPT_PATH_FLAGS="$LINKER_SCRIPT_PATH_FLAGS -T $ld_file"
    fi
done

echo ""
echo "🚀 开始独立链接..."

# 执行链接命令 (使用绝对路径)
$LLVM_COMPILER $TARGET_ARCH \
    --ld-path=$LINKER \
    -z noexecstack \
    -Wl,--cref \
    -Wl,--defsym=IDF_TARGET_ESP32=0 \
    -Wl,--Map="$OUTPUT_MAP" \
    -Wl,--no-warn-rwx-segments \
    -Wl,--orphan-handling=warn \
    -fno-rtti -fno-lto \
    -Wl,--gc-sections \
    -Wl,--warn-common \
    $LINKER_SCRIPT_PATH_FLAGS \
    -T "$LINKER_SCRIPTS_DIR/memory.ld" \
    -T "$LINKER_SCRIPTS_DIR/sections.ld" \
    "$LLGO_OBJ" \
    $LIBRARY_FILES \
    -o "$OUTPUT_ELF"

if [[ -f "$OUTPUT_ELF" ]]; then
    echo "✅ ELF文件生成成功: $OUTPUT_ELF"
    echo "📊 ELF文件大小: $(ls -lh $OUTPUT_ELF | awk '{print $5}')"
    
    # 生成二进制文件
    echo ""
    echo "🔄 转换为二进制固件..."
    
    # 使用esptool生成.bin文件
    if command -v esptool.py &> /dev/null; then
        esptool.py --chip esp32 elf2image --flash_mode dio --flash_freq 40m --flash_size 2MB \
            --elf-sha256-offset 0xb0 --min-rev-full 0 --max-rev-full 399 \
            -o "$OUTPUT_BIN" "$OUTPUT_ELF"
        
        if [[ -f "$OUTPUT_BIN" ]]; then
            echo "✅ 二进制固件生成成功: $OUTPUT_BIN"
            echo "📊 二进制文件大小: $(ls -lh $OUTPUT_BIN | awk '{print $5}')"
        fi
    else
        echo "⚠️  esptool.py 未找到，跳过.bin文件生成"
    fi
    
    echo ""
    echo "🎉 独立链接完成!"
    echo "📁 生成文件:"
    echo "   - ELF文件: $OUTPUT_ELF"
    if [[ -f "$OUTPUT_BIN" ]]; then
        echo "   - 二进制固件: $OUTPUT_BIN"
    fi
    if [[ -f "$OUTPUT_MAP" ]]; then
        echo "   - 内存映射: $OUTPUT_MAP"
    fi
    
else
    echo "❌ 链接失败!"
    exit 1
fi