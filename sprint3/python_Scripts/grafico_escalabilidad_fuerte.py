# grafico_escalabilidad_fuerte.py

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

def plot_strong_scaling():
    """
    Calcula y grafica el Speedup de la escalabilidad fuerte para OpenMP.
    """
    df = pd.read_csv("resultados_escalabilidad_fuerte.csv")
    
    # Calcular el Speedup relativo al tiempo de ejecución con 1 hilo
    t1_times = df[df['hilos'] == 1].set_index('algoritmo')['tiempo_ms']
    df['speedup'] = df.apply(
        lambda row: t1_times[row['algoritmo']] / row['tiempo_ms'],
        axis=1
    )
    
    max_hilos = df['hilos'].max()
    
    plt.style.use('seaborn-v0_8-whitegrid')
    fig, ax = plt.subplots(figsize=(12, 8))
    
    sns.lineplot(data=df, x='hilos', y='speedup', hue='algoritmo', marker='o', ax=ax)
    # Graficar el Speedup ideal (lineal)
    ax.plot([1, max_hilos], [1, max_hilos], 'k--', label='Speedup Ideal')
    
    ax.set_title('Análisis de Escalabilidad Fuerte en OpenMP (Dataset: 10M)', fontsize=16)
    ax.set_xlabel('Número de Hilos', fontsize=12)
    ax.set_ylabel('Speedup (vs. 1 Hilo)', fontsize=12)
    ax.set_xticks(np.unique(df['hilos'])) # Asegurar que todos los puntos de hilos se muestren
    ax.legend()
    ax.grid(True, which="both", ls="--")
    
    plt.tight_layout()
    plt.savefig("grafico_escalabilidad_fuerte.png", dpi=300)
    print("✅ Gráfico 'grafico_escalabilidad_fuerte.png' generado.")

if __name__ == '__main__':
    plot_strong_scaling()