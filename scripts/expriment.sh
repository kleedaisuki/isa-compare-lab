#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"
RESULT_DIR="$ROOT_DIR/docs"

RISCV_BIN="$BUILD_DIR/riscv.out"
ARM_BIN="$BUILD_DIR/arm.out"

QEMU_RISCV="qemu-riscv64"
QEMU_ARM="qemu-arm"

RISCV_OBJDUMP="riscv64-linux-gnu-objdump"
ARM_OBJDUMP="arm-linux-gnueabi-objdump"

MODES=("inc" "dec" "rand")
SIZES=(8 64 256)
RAND_SEED=12345

mkdir -p "$RESULT_DIR"

RUNTIME_CSV="$RESULT_DIR/runtime_results.csv"
STATIC_CSV="$RESULT_DIR/static_metrics.csv"

echo "arch,mode,n,seed,asm_max,ref_max,updates,ok" > "$RUNTIME_CSV"
echo "arch,total_disasm_lines,max_label_found" > "$STATIC_CSV"

echo "[1/4] Building binaries..."
make -C "$ROOT_DIR" clean
make -C "$ROOT_DIR"

if [[ ! -f "$RISCV_BIN" || ! -f "$ARM_BIN" ]]; then
    echo "Error: build outputs not found."
    exit 1
fi

extract_field() {
    local line="$1"
    local key="$2"
    echo "$line" | tr ' ' '\n' | grep "^${key}=" | cut -d'=' -f2
}

run_case() {
    local arch="$1"
    local mode="$2"
    local n="$3"
    local seed="$4"
    local cmd=()

    if [[ "$arch" == "riscv" ]]; then
        if [[ "$mode" == "rand" ]]; then
            cmd=("$QEMU_RISCV" "$RISCV_BIN" "$mode" "$n" "$seed")
        else
            cmd=("$QEMU_RISCV" "$RISCV_BIN" "$mode" "$n")
        fi
    elif [[ "$arch" == "arm" ]]; then
        if [[ "$mode" == "rand" ]]; then
            cmd=("$QEMU_ARM" "$ARM_BIN" "$mode" "$n" "$seed")
        else
            cmd=("$QEMU_ARM" "$ARM_BIN" "$mode" "$n")
        fi
    else
        echo "Error: unknown arch '$arch'" >&2
        exit 2
    fi

    local output
    output="$("${cmd[@]}")"

    local out_mode out_n out_seed asm_max ref_max updates ok
    out_mode="$(extract_field "$output" "mode")"
    out_n="$(extract_field "$output" "n")"
    out_seed="$(extract_field "$output" "seed")"
    asm_max="$(extract_field "$output" "asm_max")"
    ref_max="$(extract_field "$output" "ref_max")"
    updates="$(extract_field "$output" "updates")"
    ok="$(extract_field "$output" "ok")"

    echo "${arch},${out_mode},${out_n},${out_seed},${asm_max},${ref_max},${updates},${ok}" >> "$RUNTIME_CSV"
}

collect_static_metrics() {
    local arch="$1"
    local total_lines=0
    local has_max=0
    local dump_cmd=()

    if [[ "$arch" == "riscv" ]]; then
        dump_cmd=("$RISCV_OBJDUMP" -d "$RISCV_BIN")
    elif [[ "$arch" == "arm" ]]; then
        dump_cmd=("$ARM_OBJDUMP" -d "$ARM_BIN")
    else
        echo "Error: unknown arch '$arch'" >&2
        exit 3
    fi

    local dump
    dump="$("${dump_cmd[@]}")"

    total_lines="$(echo "$dump" | wc -l | tr -d ' ')"
    if echo "$dump" | grep -q "<max>:"; then
        has_max=1
    fi

    echo "${arch},${total_lines},${has_max}" >> "$STATIC_CSV"
}

echo "[2/4] Collecting static metrics..."
collect_static_metrics "riscv"
collect_static_metrics "arm"

echo "[3/4] Running experiment matrix..."
for arch in riscv arm; do
    for mode in "${MODES[@]}"; do
        for n in "${SIZES[@]}"; do
            if [[ "$mode" == "rand" ]]; then
                run_case "$arch" "$mode" "$n" "$RAND_SEED"
            else
                run_case "$arch" "$mode" "$n" 0
            fi
        done
    done
done

echo "[4/4] Done."
echo
echo "Generated files:"
echo "  $RUNTIME_CSV"
echo "  $STATIC_CSV"
echo
echo "Preview of runtime results:"
cat "$RUNTIME_CSV"
echo
echo "Preview of static metrics:"
cat "$STATIC_CSV"