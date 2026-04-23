# ===== 工具链 =====
RISCV_GCC = riscv64-linux-gnu-gcc
ARM_GCC   = arm-linux-gnueabi-gcc

SRC = src
BUILD = build

# ===== 输出 =====
RISCV_OUT = $(BUILD)/riscv.out
ARM_OUT   = $(BUILD)/arm.out

# ===== 默认目标 =====
all: $(RISCV_OUT) $(ARM_OUT)

# ===== 构建目录 =====
$(BUILD):
	mkdir -p $(BUILD)

# ===== RISC-V =====
$(RISCV_OUT): $(SRC)/entrance.c $(SRC)/max_riscv.s | $(BUILD)
	$(RISCV_GCC) -static $^ -o $@

# ===== ARM =====
$(ARM_OUT): $(SRC)/entrance.c $(SRC)/max_arm.s | $(BUILD)
	$(ARM_GCC) -static $^ -o $@

# ===== 清理 =====
clean:
	rm -rf $(BUILD)