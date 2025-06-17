/**
 * main_cuda.cu
 * ----------------------------------------------------------
 * CLI:
 *   ordenar_gpu <csv> <alg: ms|qs>
 *
 * • Carga el CSV con el mismo loader de Sprint 1.
 * • Llama a merge_sort_gpu() o quick_sort_gpu().
 * • Mide tiempo con util/timer.hpp.
 * • Valida contra la versión secuencial.
 */
#include "utils/csv_loader.hpp"
#include "utils/timer.hpp"
#include "utils/validation.hpp"
#include <iostream>
#include <vector>

// Declaraciones de las funciones GPU implementadas en los .cu de algoritmos
void merge_sort_gpu(std::vector<Student>&);
void quick_sort_gpu(std::vector<Student>&);

// Declaraciones de versiones secuenciales (para validación)
void merge_sort_seq(std::vector<Student>&);
void quick_sort_seq(std::vector<Student>&);

int main(int argc, char** argv)
{
    if (argc < 3) {
        std::cerr << "Uso: " << argv[0] << " <csv> <alg: ms|qs>\n";
        return 1;
    }
    const std::string csv  = argv[1];
    const std::string alg  = argv[2];

    // 1️⃣  Cargar datos
    auto datos = load_csv(csv);
    auto ref   = datos;   // copia para validación

    // 2️⃣  Ejecutar en GPU
    auto t0 = tic();
    if (alg == "ms")       merge_sort_gpu(datos);
    else if (alg == "qs")  quick_sort_gpu(datos);
    else {
        std::cerr << "Algoritmo desconocido. Use ms o qs.\n";
        return 1;
    }
    double ms = toc(t0);
    std::cout << "Tiempo GPU: " << ms << " ms\n";

    // 3️⃣  Validar contra versión secuencial
    if (alg == "ms") merge_sort_seq(ref);
    else             quick_sort_seq(ref);

    if (!equal_sorted(ref, datos)) {
        std::cerr << "❌ Orden incorrecto\n";
        return 2;
    }
    std::cout << "✔️  Resultado GPU verificado\n";
    return 0;
}
