#!/usr/bin/env bash
# Compila todos los .cu y .cpp (menos OpenMP) en un binario ordenar_gpu
set -e
cd "$(dirname "$0")"   # → sprint2/scripts
cd ..                  # → sprint2
SRC="$PWD/src"

# Ajusta compute_xx y sm_xx a TU GPU (ej.: sm_61=Pascal, sm_75=Turing, sm_80=Ampere)
ARCH="-gencode arch=compute_50,code=sm_50"

# Compilar con nvcc
nvcc -std=c++17 -O3 $ARCH \
    $(find "$SRC" -name '*.cu') \
    $(find "$SRC" -name '*.cpp' -not -name '*openmp.cpp') \
    -o ordenar_gpu

echo "🔹 Binario generado: $(pwd)/ordenar_gpu"
