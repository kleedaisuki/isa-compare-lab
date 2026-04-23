#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

/**
 * @brief 汇编实现的数组最大值函数 / Assembly implementation of array maximum
 * @param arr 输入数组指针 / Pointer to input array
 * @param n 数组长度 / Array length
 * @return 最大值 / Maximum value
 */
extern int max(int *arr, int n);

/**
 * @brief 生成递增数组 / Generate increasing array
 * @param arr 数组指针 / Array pointer
 * @param n 数组长度 / Array length
 */
static void fill_inc(int *arr, int n)
{
    for (int i = 0; i < n; ++i)
    {
        arr[i] = i + 1;
    }
}

/**
 * @brief 生成递减数组 / Generate decreasing array
 * @param arr 数组指针 / Array pointer
 * @param n 数组长度 / Array length
 */
static void fill_dec(int *arr, int n)
{
    for (int i = 0; i < n; ++i)
    {
        arr[i] = n - i;
    }
}

/**
 * @brief 生成伪随机数组 / Generate pseudo-random array
 * @param arr 数组指针 / Array pointer
 * @param n 数组长度 / Array length
 * @param seed 随机种子 / Random seed
 */
static void fill_rand(int *arr, int n, unsigned int seed)
{
    srand(seed);
    for (int i = 0; i < n; ++i)
    {
        arr[i] = rand() % 100000;
    }
}

/**
 * @brief C 参考实现：求数组最大值 / C reference implementation for max
 * @param arr 输入数组 / Input array
 * @param n 数组长度 / Array length
 * @return 最大值 / Maximum value
 */
static int max_ref(const int *arr, int n)
{
    int m = arr[0];
    for (int i = 1; i < n; ++i)
    {
        if (arr[i] > m)
        {
            m = arr[i];
        }
    }
    return m;
}

/**
 * @brief 统计“最大值更新次数” / Count number of max updates
 * @param arr 输入数组 / Input array
 * @param n 数组长度 / Array length
 * @return 更新次数 / Number of max updates
 */
static int count_updates(const int *arr, int n)
{
    int updates = 0;
    int m = arr[0];
    for (int i = 1; i < n; ++i)
    {
        if (arr[i] > m)
        {
            m = arr[i];
            updates++;
        }
    }
    return updates;
}

/**
 * @brief 打印用法说明 / Print usage information
 * @param prog 程序名 / Program name
 */
static void print_usage(const char *prog)
{
    fprintf(stderr,
            "Usage: %s <mode> <n> [seed]\n"
            "  mode: inc | dec | rand\n"
            "  n   : positive integer\n"
            "  seed: optional, used only for rand mode\n",
            prog);
}

/**
 * @brief 主函数：实验驱动 / Main function: experiment driver
 * @param argc 参数个数 / Argument count
 * @param argv 参数数组 / Argument vector
 * @return 返回码 / Exit code
 */
int main(int argc, char *argv[])
{
    if (argc < 3)
    {
        print_usage(argv[0]);
        return 1;
    }

    const char *mode = argv[1];
    int n = atoi(argv[2]);
    unsigned int seed = 12345;

    if (n <= 0)
    {
        fprintf(stderr, "Error: n must be positive.\n");
        return 2;
    }

    if (strcmp(mode, "rand") == 0 && argc >= 4)
    {
        seed = (unsigned int)strtoul(argv[3], NULL, 10);
    }

    int *arr = (int *)malloc((size_t)n * sizeof(int));
    if (!arr)
    {
        fprintf(stderr, "Error: memory allocation failed.\n");
        return 3;
    }

    if (strcmp(mode, "inc") == 0)
    {
        fill_inc(arr, n);
    }
    else if (strcmp(mode, "dec") == 0)
    {
        fill_dec(arr, n);
    }
    else if (strcmp(mode, "rand") == 0)
    {
        fill_rand(arr, n, seed);
    }
    else
    {
        fprintf(stderr, "Error: invalid mode '%s'.\n", mode);
        free(arr);
        print_usage(argv[0]);
        return 4;
    }

    int asm_result = max(arr, n);
    int ref_result = max_ref(arr, n);
    int updates = count_updates(arr, n);
    int ok = (asm_result == ref_result) ? 1 : 0;

    /*
     * 结构化输出：单行 key=value，便于脚本解析
     * Structured single-line key=value output for shell parsing.
     */
    printf("mode=%s n=%d seed=%u asm_max=%d ref_max=%d updates=%d ok=%d\n",
           mode, n, seed, asm_result, ref_result, updates, ok);

    free(arr);
    return ok ? 0 : 5;
}