#!/bin/bash

echo "=========================================="
echo "BSS段验证演示脚本"
echo "=========================================="

echo
echo "1. 编译所有程序..."
gcc -o bss_demo bss_demo.c
gcc -o bss_compare1 bss_compare.c  
gcc -o bss_compare2 bss_compare2.c

echo "编译完成！"
echo

echo "2. 文件大小对比："
echo "初始化版本 vs 未初始化版本"
ls -la bss_compare1 bss_compare2

echo
echo "3. 段大小分析："
echo "--- 初始化版本段大小 ---"
size bss_compare1
echo "--- 未初始化版本段大小 ---" 
size bss_compare2

echo
echo "4. 详细段信息 (前10行)："
echo "--- 初始化版本 ---"
objdump -h bss_compare1 | head -10
echo "--- 未初始化版本 ---"
objdump -h bss_compare2 | head -10

echo
echo "5. 运行基础演示程序："
echo "===================="
./bss_demo

echo
echo "6. 运行对比程序："
echo "--- 初始化版本输出 ---"
./bss_compare1
echo
echo "--- 未初始化版本输出 ---"
./bss_compare2

echo
echo "=========================================="
echo "演示完成！"
echo "核心发现："
echo "- 未初始化数组不占用可执行文件空间"
echo "- .bss段在程序启动时自动清零"
echo "- 大幅减少可执行文件大小"
echo "=========================================="