# grafico_escalabilidad_debil.py

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

def plot_weak_scaling():
    """
    Grafica el tiempo de ejecución para el análisis de escalabilidad débil.
    El objetivo es una línea lo más horizontal posible.
    """
    df = pd.read_csv("resultados_escalabilidad_debil.csv")

    plt.style.use('seaborn-v0_8-whitegrid')
    fig, ax = plt.subplots(figsize=(12, 8))

    sns.lineplot(data=df, x='hilos', y='tiempo_ms', hue='algoritmo', marker='o', ax=ax)

    # Añadir líneas de referencia horizontales basadas en el tiempo con 1 hilo
    for algo in df['algoritmo'].unique():
        t1_time = df[(df['hilos'] == 1) & (df['algoritmo'] == algo)]['tiempo_ms'].iloc[0]
        ax.axhline(y=t1_time, linestyle='--', label=f'Tiempo Base ({algo})')

    ax.set_title('Análisis de Escalabilidad Débil en OpenMP (Carga: 1M registros/hilo)', fontsize=16)
    ax.set_xlabel('Número de Hilos (y Millones de Registros)', fontsize=12)
    ax.set_ylabel('Tiempo de Ejecución (ms)', fontsize=12)
    ax.set_xticks(np.unique(df['hilos']))
    ax.legend(title='Algoritmo')
    ax.grid(True, which="both", ls="--")
    
    # Ajustar el límite Y para apreciar mejor las desviaciones
    ax.set_ylim(bottom=0)

    plt.tight_layout()
    plt.savefig("grafico_escalabilidad_debil.png", dpi=300)
    print("✅ Gráfico 'grafico_escalabilidad_debil.png' generado.")

if __name__ == '__main__':
    plot_weak_scaling()