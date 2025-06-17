#include "utils/csv_loader.hpp"
#include "utils/timer.hpp"
#include "utils/validation.hpp"
#include <iostream>
#include <vector>

extern void merge_sort_seq(std::vector<Student>&);
extern void merge_sort_omp(std::vector<Student>&);
extern void quick_sort_seq(std::vector<Student>&);
extern void quick_sort_omp(std::vector<Student>&);

int main(int argc,char**argv){
    if(argc<4){
        std::cerr<<"Uso: "<<argv[0]
                 <<" <csv> <alg: ms|qs> <modo: seq|omp>\n";
        return 1;
    }
    const std::string csv  = argv[1];
    const std::string alg  = argv[2];
    const std::string modo = argv[3];

    auto datos = load_csv(csv);
    auto ref   = datos;                    // copia para validación

    auto t0 = tic();
    if(alg=="ms" && modo=="seq")  merge_sort_seq(datos);
    if(alg=="ms" && modo=="omp")  merge_sort_omp(datos);
    if(alg=="qs" && modo=="seq")  quick_sort_seq(datos);
    if(alg=="qs" && modo=="omp")  quick_sort_omp(datos);
    double ms = toc(t0);

    std::cout<<"Tiempo "<<ms<<" ms\n";

    (alg=="ms" ? merge_sort_seq : quick_sort_seq)(ref);
    if(!equal_sorted(ref,datos)){
        std::cerr<<"ERROR: resultado incorrecto\n"; return 2;
    }
    std::cout<<"✔️  Resultado verificado\n";
    return 0;
}
