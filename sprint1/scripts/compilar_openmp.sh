#!/usr/bin/env bash
set -e                                  # aborta ante cualquier error

# ─── 1. Posicion  en la carpeta sprint1/scripts ───
cd "$(dirname "$0")"                    # …/sprint1/scripts
cd ..                                   # …/sprint1

# ─── 2. Ruta base al código fuente ───
SRC="$PWD/src"                          # …/sprint1/src

# ─── 3. Compilación con OpenMP ───
g++ -std=c++17 -O3 -fopenmp \
    $(find "$SRC" -name 'sequential.cpp' -o -name 'openmp.cpp') \
    "$SRC/main_openmp.cpp" \
    $(find "$SRC/utils" -name '*.cpp') \
    -o ordenar_omp

echo "🔹 Binario generado: $(pwd)/ordenar_omp (usa OpenMP)"

