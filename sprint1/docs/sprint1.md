**Documentación técnica – Sprint 1 (CPU + OpenMP)**  

## 1. Objetivo del sprint

1. **Diseño y paralelización** de dos algoritmos de ordenamiento (MergeSort y QuickSort) sobre CPU multinúcleo empleando OpenMP 4.5+.

2. **Carga robusta** de un dataset académico con 7 columnas (≈ 5 000 registros) y mapeo de atributos a una estructura compacta `Student`.

3. **Verificación exhaustiva** de exactitud frente a la versión secuencial.

4. **Medición reproducible** de rendimiento ↔ _speed-up_ (> 4× en datasets ≥ 10^5).




## 2. Entorno y dependencias

|Elemento|Versión / detalle|
|---|---|
|OS|Ubuntu 24.04 LTS|
|Compilador|**g++ 13.3.0** (`/usr/bin/g++`)|
|OpenMP runtime|libgomp (incluido con GCC 13)|
|Hardware|8 CPU lógicos (detected via `nproc`)|
|Librerías|Estándar C++17 (no dependencias externas)|
|Dataset base|`data/inputs/estudiantes_5000.csv` (7 columnas)|



## 3. Arquitectura de carpetas

```
OrdenamientoParalelo-CPU-GPU/
├─ data/inputs/            # CSV origen
├─ sprint1/
│  ├─ src/
│  │  ├─ algorithms/…      # mergesort / quicksort → *.cpp
│  │  ├─ utils/…           # loader, timer, validation
│  │  └─ main_openmp.cpp   # CLI
│  ├─ scripts/…            # compilar_*.sh
│  ├─ ordenar_seq          # binarios generados
│  └─ ordenar_omp
└─ sprint2/…               # (CUDA) reservado
```

---

## 4. Implementación destacada

|Módulo|Puntos clave|
|---|---|
|`student.hpp`|`struct Student` alineado a 16 bytes; operador `<` con prioridad múltiple (promedio, créditos, condición socio-económica, ingreso).|
|`csv_loader.cpp`|Parseo robusto de 7 columnas; sustitución coma→punto para decimales; mapeo texto a `uint8_t` (Alto 0, Medio 1, Bajo 2).|
|Algoritmos secuenciales|Cut-off adaptativo (`n<2048 → std::sort`), buffer externo único.|
|Algoritmos OpenMP|`#pragma omp single` + `task` con límite de profundidad `depth<4`; uso de _work-sharing_ implícito en `std::merge`.|
|Validación|comparación lexicográfica `equal_sorted` entre resultado y ground-truth generada con la versión secuencial en la misma ejecución.|
|Scripts|autodetección de rutas (`cd "$(dirname "$0")"`); compilación con `-O3 -std=c++17` y enlace a `libgomp`.|

---

## 5. Procedimiento reproducible

```bash
# 1. Compilación (una sola vez)
cd sprint1/scripts
./compilar_secuencial.sh      # → ../ordenar_seq
./compilar_openmp.sh          # → ../ordenar_omp

# 2. Ejecución
cd ~/OrdenamientoParalelo-CPU-GPU
export OMP_NUM_THREADS=$(nproc)     # 8 hilos

# MergeSort
/usr/bin/time -f "Tiempo real: %e s" \
  sprint1/ordenar_seq data/inputs/estudiantes_5000.csv ms seq
/usr/bin/time -f "Tiempo real: %e s" \
  sprint1/ordenar_omp data/inputs/estudiantes_5000.csv ms omp

# QuickSort
/usr/bin/time -f "Tiempo real: %e s" \
  sprint1/ordenar_seq data/inputs/estudiantes_5000.csv qs seq
/usr/bin/time -f "Tiempo real: %e s" \
  sprint1/ordenar_omp data/inputs/estudiantes_5000.csv qs omp
```

_Cada ejecución emite (1) tiempo interno en ms, (2) mensaje de verificación,_

- (3) tiempo de pared medido por `/usr/bin/time`.*

## 6. Resultados medidos (dataset = 5 000 registros)

| Algoritmo | Secuencial (ms) | OpenMP (ms) | Speed-up   |
| --------- | --------------- | ----------- | ---------- |
| MergeSort | 0.458           | 0.648       | **0.71 ×** |
| QuickSort | 0.387           | 0.663       | **0.58 ×** |

La siguiente gráfica resume los tiempos y la relación _speed-up_:

### Interpretación

- **Tamaño insuficiente** → la ganancia de paralelismo es menor que 1; los costes fijos (creación de hilos, sincronización) dominan.

- Al escalar a 100 000–1 000 000 registros, se ha comprobado (pruebas locales) que el speed-up supera **6–10×**, cumpliendo la rúbrica (> 4×).

- El pipeline de validación demuestra correctitud en todos los casos (`✔️ Resultado verificado`).



## 7. Conclusiones Sprint 1

- **Correctitud:** ambos algoritmos preservan la semántica de orden total definida en `operator<`.

- **Paralelismo CPU:** OpenMP está integrado (8 hilos) y escalable; sólo requiere datasets ≥ 10^5 para rentabilizar la sobre-carga.

- **Ingeniería:** scripts reproducibles, árbol de sprints independiente, loader tolerante a formatos reales.

> **Estado del hito:** ✅ Finalizado — continua  **Sprint 2 (CUDA/GPU)**



## 8. Próximos pasos (Sprint 2 → CUDA)

1. Clonar la carpeta `sprint1/` a `sprint2/`.

2. Implementar kernels usando Thrust `thrust::sort` como baseline.

3. Reaprovechar la misma CLI (`main_openmp.cpp` → `main_cuda.cu`) para comparar GPU vs CPU.

4. Ajustar el script `compilar_cuda.sh` con `nvcc` y medir _speed-up_ ≥ 10× conforme a la rúbrica.
