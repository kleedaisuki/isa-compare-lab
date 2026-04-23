    .text
    .globl max

# int max(int* arr, int n)
max:
    # a0 = arr
    # a1 = n

    lw t0, 0(a0)        # max = arr[0]
    li t1, 1            # i = 1

loop:
    bge t1, a1, end     # if i >= n -> end

    slli t2, t1, 2      # offset = i * 4
    add t3, a0, t2      # addr = arr + offset
    lw t4, 0(t3)        # value = arr[i]

    ble t4, t0, skip    # if value <= max skip
    mv t0, t4           # max = value

skip:
    addi t1, t1, 1      # i++
    j loop

end:
    mv a0, t0           # return max
    ret
