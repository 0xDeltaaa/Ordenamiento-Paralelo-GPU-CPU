# Ordenamiento Paralelo CPU-GPU

Este proyecto es una plataforma de comparación y visualización de algoritmos de ordenamiento implementados en C++ para CPU (secuencial y OpenMP) y GPU (CUDA), con una interfaz web moderna desarrollada en Python/Flask.

## Objetivo

El objetivo principal es analizar, comparar y visualizar el rendimiento de algoritmos de ordenamiento (MergeSort y QuickSort) ejecutados en diferentes arquitecturas (CPU secuencial, CPU paralela y GPU), usando datos reales de estudiantes. La plataforma permite experimentar con los algoritmos y observar sus diferencias de desempeño de manera interactiva.

## ¿Por qué este proyecto?

- **Aprendizaje práctico:** Permite entender cómo varía el rendimiento de los algoritmos de ordenamiento al aprovechar la paralelización en CPU y GPU.
- **Visualización clara:** La interfaz web facilita la comparación visual de tiempos y resultados, haciendo más didáctico el análisis.
- **Reproducibilidad:** Cualquier persona puede compilar, ejecutar y comparar los algoritmos en su propia máquina, con o sin GPU.
- **Extensible:** El código está organizado para facilitar la incorporación de nuevos algoritmos o datasets.

---

# Requisitos e Instrucciones para Ejecutar el Proyecto

## Requisitos Generales

- **Python 3.8+**
- **Flask** (para la interfaz web)
- **g++** (para compilar código C++/OpenMP)
- **nvcc** (para compilar código CUDA, si se desea usar GPU)
- **NVIDIA GPU** (opcional, solo si se usará CUDA)
- **Bootstrap y Chart.js** (ya incluidos vía CDN en la plantilla)

## Instalación de Dependencias Python

```sh
pip install flask
```

## Estructura del Proyecto

```
OrdenamientoParalelo-CPU-GPU/
├── app.py
├── templates/
│   └── index.html
├── data/inputs/estudiantes_5000.csv
├── sprint1/
│   ├── scripts/
│   │   ├── compilar_secuencial.sh
│   │   ├── compilar_openmp.sh
│   │   └── compilar_cuda.sh
│   └── ...
├── sprint2/
│   ├── scripts/
│   │   ├── compilar_secuencial.sh
│   │   ├── compilar_openmp.sh
│   │   └── compilar_cuda.sh
│   └── ...
```

## Compilación de Binarios

### Sprint 1 (CPU)

```sh
cd sprint1/scripts
./compilar_secuencial.sh
./compilar_openmp.sh
```

### Sprint 2 (GPU y CPU)

```sh
cd sprint2/scripts
./compilar_cuda.sh   # Solo si tienes GPU y CUDA
./compilar_secuencial.sh
./compilar_openmp.sh
```

## Ejecución de la Interfaz Web

Desde la raíz del proyecto:

```sh
python3 app.py
```

Luego abre en tu navegador:

```
http://localhost:5000
```

## Notas
- El archivo de entrada por defecto es `data/inputs/estudiantes_5000.csv`.
- Los binarios deben estar compilados antes de usar la interfaz web.
- Si no tienes GPU, puedes usar solo los modos Secuencial y OpenMP.
- Si quieres cambiar el archivo de entrada, actualiza la ruta en `app.py`.

## Requisitos para CUDA (opcional)
- Driver NVIDIA instalado
- Toolkit CUDA instalado (`nvcc` en PATH)
- GPU compatible

---

**¡Listo para comparar algoritmos de ordenamiento en CPU y GPU con una interfaz moderna!**
