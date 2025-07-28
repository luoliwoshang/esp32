#include <stdio.h>

// 版本2: 所有数组都未初始化 (放在.bss段)
int version2_array1[10000]; // 未初始化，在.bss段，运行时自动清零
int version2_array2[10000]; // 未初始化，在.bss段
int version2_array3[10000]; // 未初始化，在.bss段

int main() {
    printf("版本2: 所有数组都未初始化\n");
    printf("总共3个10000元素的int数组 = %lu bytes\n", 
           3 * 10000 * sizeof(int));
    
    printf("验证.bss段自动清零:\n");
    printf("array1[0] = %d, array1[1] = %d\n", version2_array1[0], version2_array1[1]);
    printf("array2[0] = %d, array2[1] = %d\n", version2_array2[0], version2_array2[1]);
    printf("array3[0] = %d, array3[1] = %d\n", version2_array3[0], version2_array3[1]);
    
    return 0;
}