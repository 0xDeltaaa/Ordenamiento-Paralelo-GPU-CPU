#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"   # → sprint1/scripts
cd ..                  # → sprint1
SRC="$PWD/src"

g++ -std=c++17 -O3 -fopenmp \
    $(find "$SRC" -name 'sequential.cpp' -o -name 'openmp.cpp') \
    "$SRC/main_openmp.cpp" \
    $(find "$SRC/utils" -name '*.cpp') \
    -o ordenar_seq

echo "🔹 Binario generado: $(pwd)/ordenar_seq"

