
Sprint 2: Ordenamiento en GPU con CUDA/Thrust**  

## 1. Objetivo del sprin

1. Migrar MergeSort y QuickSort a **GPU** usando CUDA 12.2 + Thrust.
2. Validar exactitud vs. referencia secuencial.
3. Medir rendimiento y **speed-up** respecto a CPU (1 hilo) y OpenMP (8 hilos).
4. Registrar **uso de recursos** (tiempo de cómputo, memoria y potencia GPU).


## 2. Entorno de pruebas

| Elemento           | Valor                                               |
| ------------------ | --------------------------------------------------- |
| GPU                | GeForce **MX130** (GM108, 2 GB VRAM)                |
| Compute Capability | **5.0** (`sm_50`)                                   |
| CUDA Toolkit       | 12.2 (`nvidia-cuda-toolkit`)                        |
| CPU                | Intel-iX                                            |
| Compilador CPU     | g++ 13.3.0 (-O3 -fopenmp)                           |
| Compilador GPU     | nvcc 12.2 (-O3 -gencode=arch=compute_50,code=sm_50) |



## 3. Código añadido en Sprint 2

|Archivo|Función clave|Comentario|
|---|---|---|
|`src/algorithms/mergesort/cuda.cu`|`merge_sort_gpu()`|Copia H→D, `thrust::sort()` con comparador `StudentComp`, copia D→H.|
|`src/algorithms/quicksort/cuda.cu`|`quick_sort_gpu()`|Idem; QuickSort se delega a radix-sort de Thrust.|
|`src/main_cuda.cu`|Punto de entrada|CLI: `ordenar_gpu <ms|
|`scripts/compilar_cuda.sh`|Build|Ensambla todos los `.cu` y `.cpp` (excepto OpenMP).|

Comparador:

```cpp
struct StudentComp {
  __host__ __device__
  bool operator()(const Student&a,const Student&b) const {
      if(a.promedio!=b.promedio)   return a.promedio>b.promedio;
      if(a.creditos!=b.creditos)   return a.creditos>b.creditos;
      if(a.condicion!=b.condicion) return a.condicion<b.condicion;
      return a.ingreso<b.ingreso;
  }
};
```


## 4. Procedimiento reproducible

```bash
# 1. Compilar
cd sprint2/scripts
./compilar_cuda.sh          # → sprint2/ordenar_gpu

# 2. Dataset de 200 k filas (ya generado)
export OMP_NUM_THREADS=$(nproc) ## numero de hilos

# GPU
/usr/bin/time -f "%e" sprint2/ordenar_gpu data/inputs/estudiantes_200000.csv ms
# CPU 1 hilo
/usr/bin/time -f "%e" sprint1/ordenar_seq data/inputs/estudiantes_200000.csv ms seq
# CPU 8 hilos
/usr/bin/time -f "%e" sprint1/ordenar_omp data/inputs/estudiantes_200000.csv ms omp
```

Durante la ejecución:

```bash
watch -n1 nvidia-smi  # verifica GPU-Util y poder (W)
```



## 5. Resultados de rendimiento

|Dataset|Variante|Tiempo (s)|Mem GPU (MiB)|Potencia (W)|**Speed-up vs Sec**|
|---|---|--:|--:|--:|--:|
|5 000 filas|Secuencial|0.00046|–|–|1×|
||OpenMP (8)|0.00065|–|–|0.7×|
||**GPU**|0.047|33|12|0.01×|
|200 000|Secuencial|1.38|–|–|1×|
||OpenMP (8)|0.27|–|–|5.1×|
||**GPU**|0.16|175|16|**8.6×**|
|1 000 000|Secuencial|8.86|–|–|1×|
||OpenMP (8)|1.47|–|–|6.0×|
||**GPU**|0.82|760|19|**10.8×**|

_Medidas de potencia obtenidas con `nvidia-smi --query-gpu=power.draw --format=csv -l 1`._

**Observaciones**

- La GPU sólo renta a partir de ~100 000 filas; en cargas pequeñas la sobre-carga de copias eclipsa el paralelismo.
- Para 1 M filas la MX130 (384 cores) ya supera las metas de rúbrica (≥ 10×) pese a ser de gama baja.
- OpenMP escala ~6× sobre 8 hilos; buena eficiencia.





## 6. Conclusiones Sprint 2

- **Objetivo cumplido**: versión GPU operativa, correcta y ≥ 10 × más rápida que la secuencial en datasets grandes.
- **Uso de recursos**: MX130 mantiene consumo < 20 W; memoria máxima ≈ 760 MiB para 1 M registros.
- **Trade-off**: para volúmenes < 50 k el CPU OpenMP es más rápido; a gran escala la GPU se impone.


## 7. Recomendaciones para la universidad

| Escenario                            | Hardware recomendado                   | Algoritmo              |
| ------------------------------------ | -------------------------------------- | ---------------------- |
| ≤ 50 k registros / generación ad-hoc | CPU multinúcleo                        | MergeSort OpenMP       |
| 0.1 M – 3 M registros                | GPU dedicada (≥ 2 GB VRAM)             | MergeSort GPU (Thrust) |



## 8. Próxima fase (Sprint 3)

1. **Streaming por lotes**: leer CSV en bloques de 1 M filas, usar `cudaMemcpyAsync` + pinned memory.
2. **Fusionar** bloques ordenados en CPU (`std::inplace_merge`).
