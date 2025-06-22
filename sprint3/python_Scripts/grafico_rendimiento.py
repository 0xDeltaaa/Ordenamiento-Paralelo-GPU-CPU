# grafico_rendimiento.py

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

def plot_rendimiento_general():
    """
    Genera un gráfico de líneas comparando el tiempo de ejecución de todas las
    implementaciones a través de diferentes tamaños de dataset.
    """
    df = pd.read_csv("resultados_rendimiento_general.csv")
    
    # Crear una etiqueta única para cada línea del gráfico (ej: "ms-gpu")
    df['implementacion'] = df['algoritmo'] + '-' + df['modo']
    
    plt.style.use('seaborn-v0_8-whitegrid')
    fig, ax = plt.subplots(figsize=(12, 8))
    
    palette = {
        'ms-seq': 'lightblue',         # CPU base, MergeSort
        'qs-seq': 'cornflowerblue',    # CPU base, QuickSort
        'ms-omp': 'blue',              # CPU Paralelo, MergeSort
        'qs-omp': 'darkblue',          # CPU Paralelo, QuickSort
        'ms-gpu': 'lightgreen',        # GPU, MergeSort
        'qs-gpu': 'green'              # GPU, QuickSort
    }
    
    sns.lineplot(data=df, x='dataset_size', y='tiempo_ms', hue='implementacion', 
                 style='algoritmo', marker='o', ax=ax, palette=palette)
    
    ax.set_xscale('log')
    ax.set_yscale('log')
    
    ax.set_title('Rendimiento General: Tiempo de Ejecución vs. Tamaño del Dataset', fontsize=16)
    ax.set_xlabel('Tamaño del Dataset (Nº de registros) - Escala Logarítmica', fontsize=12)
    ax.set_ylabel('Tiempo de Ejecución (ms) - Escala Logarítmica', fontsize=12)
    ax.legend(title='Implementación')
    ax.grid(True, which="both", ls="--")
    
    plt.tight_layout()
    plt.savefig("grafico_rendimiento_general.png", dpi=300)
    print("✅ Gráfico 'grafico_rendimiento_general.png' generado.")

def plot_speedup_max_dataset():
    """
    Calcula y grafica el Speedup para el dataset más grande (10M)
    comparando las versiones paralelas (OMP, GPU) con la secuencial.
    """
    df = pd.read_csv("resultados_rendimiento_general.csv")
    
    # Filtrar solo para el dataset más grande
    df_10m = df[df['dataset_size'] == 10000000].copy()
    
    if df_10m.empty:
        print("⚠️ No se encontraron datos para 10M de registros. Omitiendo gráfico de Speedup.")
        return
        
    # Separar tiempos secuenciales para usarlos como base
    seq_times = df_10m[df_10m['modo'] == 'seq'].set_index('algoritmo')['tiempo_ms']
    
    # Filtrar solo versiones paralelas
    parallel_df = df_10m[df_10m['modo'].isin(['omp', 'gpu'])].copy()
    
    # Calcular Speedup
    parallel_df['speedup'] = parallel_df.apply(
        lambda row: seq_times[row['algoritmo']] / row['tiempo_ms'],
        axis=1
    )
    
    parallel_df['implementacion'] = parallel_df['algoritmo'] + '-' + parallel_df['modo']
    
    plt.style.use('seaborn-v0_8-whitegrid')
    fig, ax = plt.subplots(figsize=(10, 7))
    
    bars = sns.barplot(data=parallel_df, x='implementacion', y='speedup', hue='modo', ax=ax, dodge=False)
    
    # Añadir etiquetas de valor sobre las barras
    for bar in bars.patches:
        ax.text(bar.get_x() + bar.get_width() / 2,
                bar.get_height(),
                f'{bar.get_height():.1f}x',
                ha='center', va='bottom',
                fontsize=12)

    ax.set_title('Speedup vs. Secuencial (Dataset de 10M de registros)', fontsize=16)
    ax.set_xlabel('Implementación Paralela', fontsize=12)
    ax.set_ylabel('Speedup (Factor de Aceleración)', fontsize=12)
    ax.legend(title='Plataforma')

    plt.tight_layout()
    plt.savefig("grafico_speedup_10M.png", dpi=300)
    print("✅ Gráfico 'grafico_speedup_10M.png' generado.")


if __name__ == '__main__':
    plot_rendimiento_general()
    plot_speedup_max_dataset()