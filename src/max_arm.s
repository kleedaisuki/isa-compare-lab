    .text
    .global max

# int max(int* arr, int n)
max:
    # r0 = arr
    # r1 = n

    LDR r2, [r0]        @ max = arr[0]
    MOV r3, #1          @ i = 1

loop:
    CMP r3, r1
    BGE end             @ if i >= n -> end

    LSL r4, r3, #2      @ offset = i * 4
    ADD r5, r0, r4      @ addr = arr + offset
    LDR r6, [r5]        @ value = arr[i]

    CMP r6, r2
    BLE skip            @ if value <= max skip
    MOV r2, r6          @ max = value

skip:
    ADD r3, r3, #1      @ i++
    B loop

end:
    MOV r0, r2          @ return max
    BX lr
