#!/usr/bin/env bash
# analisis_completo.sh
#
# Realiza un benchmark completo para generar datos para 3 análisis clave:
# 1. Rendimiento General (Secuencial vs. OpenMP vs. GPU).
# 2. Escalabilidad Fuerte de OpenMP (variando hilos, problema fijo).
# 3. Escalabilidad Débil de OpenMP (variando hilos y problema proporcionalmente).

set -e
export LC_NUMERIC="C"

# --- SECCIÓN DE CONFIGURACIÓN ---
# Colores para la salida
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Rutas a los ejecutables
BIN_SEQ="sprint1/ordenar_seq"
BIN_OMP="sprint1/ordenar_omp"
BIN_GPU="sprint2/ordenar_gpu"

# Rutas a los archivos de datos
declare -A DATASETS
DATASETS=(
    ["5K"]="/home/terry/Downloads/CDP/Ordenamiento-Paralelo-GPU-CPU/data/inputs/estudiantes_5000.csv"
    ["100K"]="/home/terry/Downloads/CDP/Ordenamiento-Paralelo-GPU-CPU/data/inputs/estudiantes_100k.csv"
    ["1M"]="/home/terry/Downloads/CDP/Ordenamiento-Paralelo-GPU-CPU/data/inputs/estudiantes_1M.csv"
    ["2M"]="/home/terry/Downloads/CDP/Ordenamiento-Paralelo-GPU-CPU/data/inputs/estudiantes_2M.csv"
    ["4M"]="/home/terry/Downloads/CDP/Ordenamiento-Paralelo-GPU-CPU/data/inputs/estudiantes_4M.csv"
    ["5M"]="/home/terry/Downloads/CDP/Ordenamiento-Paralelo-GPU-CPU/data/inputs/estudiantes_5M.csv"
    ["8M"]="/home/terry/Downloads/CDP/Ordenamiento-Paralelo-GPU-CPU/data/inputs/estudiantes_8M.csv"
    ["10M"]="/home/terry/Downloads/CDP/Ordenamiento-Paralelo-GPU-CPU/data/inputs/estudiantes_10M.csv"
)

# Parámetros para los experimentos
MAX_THREADS=$(nproc) # Máximo de hilos para OMP
REPETICIONES=3       # Número de veces que se ejecuta cada prueba para obtener el mejor tiempo

# --- FUNCIÓN DE BENCHMARK MEJORADA ---
# Parámetros: 1:binario, 2:archivo_datos, 3:algoritmo, 4:modo, 5:hilos, 6:dataset_label, 7:csv_salida
run_benchmark() {
    local binary_path=$1
    local data_file=$2
    local algorithm=$3
    local mode=$4
    local threads=$5
    local dataset_label=$6
    local output_csv=$7

    # Asignar OMP_NUM_THREADS solo si es relevante
    if [[ "$mode" == "omp" ]]; then
        export OMP_NUM_THREADS=$threads
    fi
    
    local best_time=999999
    echo -ne "  > Probando ${dataset_label} | ${algorithm} | ${mode} | hilos:${threads}..."
    
    for (( i=1; i<=$REPETICIONES; i++ )); do
        # Ejecutar el binario desde su directorio para que encuentre las dependencias si es necesario
        local output=$(./"$binary_path" "$data_file" "$algorithm" "$mode" 2>&1)
        local time=$(echo "$output" | grep -o 'Tiempo.*[0-9.]\+.*ms' | grep -o '[0-9.]\+')
        
        if [[ -n "$time" && "$time" != "0" ]]; then
            if (( $(echo "$time < $best_time" | bc -l) )); then
                best_time=$time
            fi
        else
            echo -e " ${RED}Fallo en la ejecución o tiempo cero.${NC}"
            return 1 # Falla si el comando no produce un tiempo válido
        fi
    done
    
    echo -e "\r  ${GREEN}✔${NC} ${dataset_label} | ${algorithm} | ${mode} | hilos:${threads} | ${GREEN}${best_time} ms${NC}"
    
    # Extraer el número de registros del nombre del dataset
    local size_num=$(echo "$dataset_label" | grep -o '[0-9]\+' | head -1)
    local size_unit=$(echo "$dataset_label" | grep -o '[KMG]')
    case $size_unit in
        K) size_num=$((size_num * 1000)) ;;
        M) size_num=$((size_num * 1000000)) ;;
        G) size_num=$((size_num * 1000000000)) ;;
    esac
    if [[ "$dataset_label" == "5000" ]]; then size_num=5000; fi


    # Escribir en el CSV correcto según el experimento
    if [[ "$output_csv" == "resultados_rendimiento_general.csv" ]]; then
        echo "$size_num,$algorithm,$mode,$threads,$best_time" >> "$output_csv"
    elif [[ "$output_csv" == "resultados_escalabilidad_fuerte.csv" ]]; then
        echo "$algorithm,$threads,$best_time" >> "$output_csv"
    elif [[ "$output_csv" == "resultados_escalabilidad_debil.csv" ]]; then
        local carga_por_hilo=$((size_num / threads))
        echo "$algorithm,$threads,$size_num,$carga_por_hilo,$best_time" >> "$output_csv"
    fi
}


# --- SCRIPT PRINCIPAL ---
echo -e "${BLUE}🚀 INICIANDO ANÁLISIS DE RENDIMIENTO COMPLETO${NC}"
echo "================================================="

echo "🔧 Compilando todas las versiones (modo depuración)..."

echo -e "\n--- [Depuración] Compilando Sprint 1 (CPU)..."
(cd sprint1 && bash scripts/compilar_openmp.sh && bash scripts/compilar_secuencial.sh)
echo "--- [Depuración] Finalizada compilación de Sprint 1."

echo -e "\n--- [Depuración] Compilando Sprint 2 (GPU)..."
(cd sprint2 && bash scripts/compilar_cuda.sh)
echo "--- [Depuración] Finalizada compilación de Sprint 2."


echo -e "\n✅ Compilación finalizada."

# =========== PARTE 1: BENCHMARK GENERAL Y SPEEDUP ===========
echo -e "${YELLOW}--- Experimento 1: Rendimiento General (OpenMP usa ${MAX_THREADS} hilos) ---${NC}"
RESULTS_GENERAL_CSV="resultados_rendimiento_general.csv"
echo "dataset_size,algoritmo,modo,hilos,tiempo_ms" > "$RESULTS_GENERAL_CSV"

for dataset_label in "5K" "100K" "1M" "5M" "10M"; do
    data_file=${DATASETS[$dataset_label]}
    for algo in "ms" "qs"; do
        run_benchmark "$BIN_SEQ" "$data_file" "$algo" "seq" "1" "$dataset_label" "$RESULTS_GENERAL_CSV"
        run_benchmark "$BIN_OMP" "$data_file" "$algo" "omp" "$MAX_THREADS" "$dataset_label" "$RESULTS_GENERAL_CSV"
        run_benchmark "$BIN_GPU" "$data_file" "$algo" "gpu" "N/A" "$dataset_label" "$RESULTS_GENERAL_CSV"
    done
done
echo ""

# =========== PARTE 2: ANÁLISIS DE ESCALABILIDAD FUERTE ===========
echo -e "${YELLOW}--- Experimento 2: Análisis de Escalabilidad Fuerte (Dataset Fijo: 10M) ---${NC}"
RESULTS_STRONG_CSV="resultados_escalabilidad_fuerte.csv"
echo "algoritmo,hilos,tiempo_ms" > "$RESULTS_STRONG_CSV"
DATA_FILE_STRONG=${DATASETS["10M"]}

for algo in "ms" "qs"; do
    for threads in $(seq 1 $MAX_THREADS); do
      if (( (threads > 1) && (threads % 2 != 0) && (threads != 1) )); then continue; fi # Usa 1, 2, 4, 6, 8...
      run_benchmark "$BIN_OMP" "$DATA_FILE_STRONG" "$algo" "omp" "$threads" "10M" "$RESULTS_STRONG_CSV"
    done
done
echo ""

# =========== PARTE 3: ANÁLISIS DE ESCALABILIDAD DÉBIL ===========
echo -e "${YELLOW}--- Experimento 3: Análisis de Escalabilidad Débil (Carga por Hilo: 1M) ---${NC}"
RESULTS_WEAK_CSV="resultados_escalabilidad_debil.csv"
echo "algoritmo,hilos,dataset_size,carga_por_hilo,tiempo_ms" > "$RESULTS_WEAK_CSV"

for algo in "ms" "qs"; do
    for threads in 1 2 4 8; do
      # Selecciona el dataset correspondiente para mantener la carga por hilo
      dataset_label_weak="${threads}M"
      if [[ $threads -ge $MAX_THREADS ]]; then break; fi
      if [[ -z "${DATASETS[$dataset_label_weak]}" ]]; then
          echo "  > Omitiendo: No se encontró el dataset para ${threads} hilos (${dataset_label_weak})."
          continue
      fi
      data_file_weak=${DATASETS[$dataset_label_weak]}
      run_benchmark "$BIN_OMP" "$data_file_weak" "$algo" "omp" "$threads" "$dataset_label_weak" "$RESULTS_WEAK_CSV"
    done
done
echo ""


echo "================================================="
echo -e "${GREEN}🎉 Análisis completado.${NC}"
echo ""
echo "Se han generado 3 archivos CSV:"
echo "1. ${GREEN}resultados_rendimiento_general.csv${NC}"
echo "2. ${GREEN}resultados_escalabilidad_fuerte.csv${NC}"
echo "3. ${GREEN}resultados_escalabilidad_debil.csv${NC}"