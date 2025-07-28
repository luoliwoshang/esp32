#include <stdio.h>
#include <stdlib.h>

// .data段 - 有初始值的全局变量
int initialized_small = 42;
int initialized_array[1000] = {1, 2, 3, 4, 5};  // 4KB，存储在可执行文件中

// .bss段 - 未初始化的全局变量
int uninitialized_small;
int uninitialized_array[10000];  // 40KB，不存储在可执行文件中！
int another_big_array[20000];    // 80KB，也不存储在可执行文件中！

// .rodata段 - 只读数据
const char* message = "Hello from .rodata segment";

void print_addresses_and_values() {
    printf("=== 内存地址和初始值验证 ===\n");
    
    // 打印地址，观察段的分布
    printf("\n地址分布:\n");
    printf("函数(.text):           %p\n", print_addresses_and_values);
    printf("字符串(.rodata):       %p\n", message);
    printf("初始化小变量(.data):   %p\n", &initialized_small);
    printf("初始化数组(.data):     %p\n", initialized_array);
    printf("未初始化小变量(.bss):  %p\n", &uninitialized_small);
    printf("未初始化数组(.bss):    %p\n", uninitialized_array);
    printf("另一个大数组(.bss):    %p\n", another_big_array);
    
    // 验证.bss段确实被初始化为0
    printf("\n.bss段初始值验证 (应该都是0):\n");
    printf("uninitialized_small = %d\n", uninitialized_small);
    printf("uninitialized_array[0] = %d\n", uninitialized_array[0]);
    printf("uninitialized_array[999] = %d\n", uninitialized_array[999]);
    printf("another_big_array[0] = %d\n", another_big_array[0]);
    printf("another_big_array[19999] = %d\n", another_big_array[19999]);
    
    // 验证.data段有正确的初始值
    printf("\n.data段初始值验证:\n");
    printf("initialized_small = %d\n", initialized_small);
    printf("initialized_array[0] = %d\n", initialized_array[0]);
    printf("initialized_array[4] = %d\n", initialized_array[4]);
    
    // 计算段的大小
    printf("\n段大小估算:\n");
    printf(".data段大约: %lu bytes (包含初始化数据)\n", 
           sizeof(initialized_small) + sizeof(initialized_array));
    printf(".bss段大约: %lu bytes (不占用文件空间!)\n",
           sizeof(uninitialized_small) + sizeof(uninitialized_array) + sizeof(another_big_array));
}

int main() {
    printf("BSS段验证程序\n");
    printf("编译后用 'size bss_demo' 命令查看段大小\n");
    
    print_addresses_and_values();
    
    // 修改一些.bss段的值，证明它们是可写的
    printf("\n=== 修改.bss段变量 ===\n");
    uninitialized_small = 100;
    uninitialized_array[0] = 200;
    uninitialized_array[999] = 300;
    
    printf("修改后:\n");
    printf("uninitialized_small = %d\n", uninitialized_small);
    printf("uninitialized_array[0] = %d\n", uninitialized_array[0]);
    printf("uninitialized_array[999] = %d\n", uninitialized_array[999]);
    
    return 0;
}