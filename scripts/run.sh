#!/usr/bin/env bash

set -e

# ===== 可配置 =====
RISCV_BIN="build/riscv.out"
ARM_BIN="build/arm.out"

QEMU_RISCV="qemu-riscv64"
QEMU_ARM="qemu-arm"

echo "=============================="
echo " Running RISC-V version"
echo "=============================="
$QEMU_RISCV $RISCV_BIN

echo
echo "=============================="
echo " Running ARM version"
echo "=============================="
$QEMU_ARM $ARM_BIN

echo
echo "=============================="
echo " Disassembly (RISC-V)"
echo "=============================="
riscv64-linux-gnu-objdump -d $RISCV_BIN | head -n 40

echo
echo "=============================="
echo " Disassembly (ARM)"
echo "=============================="
arm-linux-gnueabi-objdump -d $ARM_BIN | head -n 40

echo
echo "Instruction count (RISC-V):"
riscv64-linux-gnu-objdump -d $RISCV_BIN | grep -c "^\s"

echo
echo "Instruction count (ARM):"
arm-linux-gnueabi-objdump -d $ARM_BIN | grep -c "^\s"