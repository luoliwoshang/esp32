#include <stdio.h>

// 版本1: 所有数组都有初始值 (放在.data段)
int version1_array1[10000] = {1}; // 只初始化第一个元素，其余为0，但整个数组在.data段
int version1_array2[10000] = {0}; // 全部初始化为0，但仍在.data段
int version1_array3[10000] = {2}; // 只初始化第一个元素为2

int main() {
    printf("版本1: 所有数组都有初始值\n");
    printf("总共3个10000元素的int数组 = %lu bytes\n", 
           3 * 10000 * sizeof(int));
    
    printf("验证初始值:\n");
    printf("array1[0] = %d, array1[1] = %d\n", version1_array1[0], version1_array1[1]);
    printf("array2[0] = %d, array2[1] = %d\n", version1_array2[0], version1_array2[1]);
    printf("array3[0] = %d, array3[1] = %d\n", version1_array3[0], version1_array3[1]);
    
    return 0;
}