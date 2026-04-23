#include <stdio.h>

/**
 * @brief 找数组最大值（由汇编实现）
 * @param arr 输入数组
 * @param n 数组长度
 * @return 最大值
 */
extern int max(int *arr, int n);

int main(void)
{
    int arr[] = {3, 7, 2, 9, 5, 8};
    int n = sizeof(arr) / sizeof(arr[0]);

    int result = max(arr, n);

    printf("Max = %d\n", result);

    return 0;
}
