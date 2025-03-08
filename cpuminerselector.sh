#!/bin/bash

echo "🔍 Detecting best cpuminer version for your CPU..."

Get CPU flags
CPU_FLAGS=$(grep -m1 'flags' /proc/cpuinfo)

Function to check for CPU feature support
has_flag() {
echo "$CPU_FLAGS" | grep -qw "$1"
}

Determine best version based on CPU support
if has_flag "avx512f" && has_flag "sha_ni" && has_flag "vaes"; then
MINER_BIN="cpuminer-avx512-sha-vaes"
elif has_flag "avx512f"; then
MINER_BIN="cpuminer-avx512"
elif has_flag "avx2" && has_flag "sha_ni" && has_flag "vaes"; then
MINER_BIN="cpuminer-avx2-sha-vaes"
elif has_flag "avx2" && has_flag "sha_ni"; then
MINER_BIN="cpuminer-avx2-sha"
elif has_flag "avx2"; then
MINER_BIN="cpuminer-avx2"
elif has_flag "avx" && has_flag "aes"; then
MINER_BIN="cpuminer-avx-aes"
elif has_flag "avx"; then
MINER_BIN="cpuminer-avx"
elif has_flag "sse4_2" && has_flag "aes"; then
MINER_BIN="cpuminer-aes-sse42"
elif has_flag "sse2"; then
MINER_BIN="cpuminer-sse2"
else
echo "❌ No compatible instruction set found. Your CPU may be too old."
exit 1
fi

echo "✅ Best version detected: $MINER_BIN"

Verify the binary exists before running it
if [[ ! -f "./$MINER_BIN" ]]; then
echo "❌ Error: Selected binary '$MINER_BIN' not found!"
exit 1
fi

Run a benchmark test with the correct algorithm
echo "⚡ Running benchmark to verify performance..."
./$MINER_BIN --benchmark --algo=x11kvs

echo "🚀 Auto-selection complete. Use '$MINER_BIN' for the best mining performance!"
