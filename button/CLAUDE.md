# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
This is an ESP32 button monitoring project using ESP-IDF (Espressif IoT Development Framework). The project demonstrates basic GPIO input reading on ESP32 microcontrollers.

## Development Commands

### Build and Flash
- `idf.py build` - Build the project
- `idf.py -p /dev/tty.usbserial-10 flash monitor` - Flash to device and monitor output
- `idf.py clean` - Clean build artifacts
- `idf.py menuconfig` - Configure project settings

### Monitoring
- `idf.py monitor` - Monitor serial output from device
- `idf.py -p /dev/tty.usbserial-10 monitor` - Monitor with specific port

## Architecture
- **main/button.c**: Main application logic that continuously reads GPIO34 pin state and prints the result
- **CMakeLists.txt**: Root project configuration for ESP-IDF
- **main/CMakeLists.txt**: Component-level build configuration
- **sdkconfig**: ESP-IDF configuration file (auto-generated)

## Hardware Configuration
- Button connected to GPIO34 (input-only pin on ESP32)
- GPIO34 is configured as input mode only (hardware limitation)
- 200ms polling interval for button state

## Code Notes
- Uses FreeRTOS tasks and delay functions (`vTaskDelay`)
- GPIO operations use ESP-IDF driver API (`gpio_*` functions)
- Chinese comments are intentional and part of the original code style
- **Modified for LLVM compiler integration**: All ESP-IDF functions now declared as `extern` to allow linking with LLVM-compiled .o files

## LLVM编译器集成进展

### 最终目标
这个LLVM编译器的最终目标是**完全脱离ESP-IDF来构建程序**：
- 编译器将持有所有ESP-IDF所需的.a文件
- 将这些.a文件与编译的源文件链接到一起
- 最终通过`idf.py flash`烧录到ESP32

### 当前状态 ✅ 验证成功！
- **里程碑达成 (2025-07-25)**: LLVM编译器成功生成xtensa-esp32-elf目标文件并在ESP32上正常运行
- 编译命令: `clang -o ./llgo.o --target=xtensa-esp32-elf -c button.c`  
- 构建命令: `idf.py build` → `idf.py flash monitor`
- 运行结果: 按钮监控功能完全正常，证明了C ABI兼容性

### 技术路径
```
当前阶段: [LLVM编译器] → [.o文件] → [通过extern声明的.c文件链接] → [ESP-IDF构建]
最终目标: [LLVM编译器] → [.o文件] → [内置.a文件链接] → [直接烧录，脱离ESP-IDF]
```

详细进展记录见: [项目进展记录.md](./项目进展记录.md)

## LLVM Compiler Integration Objectives
- The LLVM compiler's ultimate goal is to build a program independent of ESP-IDF
- It will retain all required .a files from ESP-IDF
- Compiler will link these .a files with compiled source files
- Final deployment through `idf.py flash`
- Current status: Can only build .o files
- Temporarily simulating compiler behavior through a single .c file

## 项目进展记录
- 当前正在进行LLVM编译器集成，探索独立于ESP-IDF构建程序的可能性
- 目前已经能够成功编译单个.c文件，但仍需解决外部符号链接问题
- 正在研究如何在不依赖ESP-IDF编译系统的情况下链接必要的库文件

## 发现和使用方式
- 记录目前的发现和使用方式等等