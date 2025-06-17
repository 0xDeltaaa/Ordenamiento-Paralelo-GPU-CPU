from flask import Flask, render_template, request, jsonify
import subprocess
import os
import csv
import re

app = Flask(__name__)

# Configuración de rutas y binarios
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_FILES = {
    '5000': os.path.abspath(os.path.join(BASE_DIR, 'data/inputs/estudiantes_5000.csv')),
    '5M': os.path.abspath(os.path.join(BASE_DIR, 'data/inputs/estudiantes_5M.csv')),
    '10M': os.path.abspath(os.path.join(BASE_DIR, 'data/inputs/estudiantes_10M.csv')),
}
DATA_PATH = DATA_FILES['5000']  # Valor por defecto
SPRINT1_BIN = {
    'seq': os.path.abspath(os.path.join(BASE_DIR, 'sprint1/ordenar_seq')),
    'omp': os.path.abspath(os.path.join(BASE_DIR, 'sprint1/ordenar_omp')),
}
SPRINT2_BIN = {
    'cuda': os.path.abspath(os.path.join(BASE_DIR, 'sprint2/ordenar_gpu')),
}

# Historial en memoria
history = []

# Leer los primeros N estudiantes del CSV

def get_sample_students(n=10, dataset='5000'):
    students = []
    with open(DATA_FILES[dataset], newline='') as csvfile:
        reader = csv.reader(csvfile)
        headers = next(reader)
        for i, row in enumerate(reader):
            if i >= n:
                break
            students.append(row)
    return headers, students

# Ejecutar el binario correspondiente
def run_sort(alg, mode, n=10, dataset='5000'):
    data_path = DATA_FILES[dataset]
    if mode == 'cuda':
        bin_path = SPRINT2_BIN['cuda']
        args = [bin_path, data_path, alg]
    elif mode in SPRINT2_BIN:
        bin_path = SPRINT2_BIN[mode]
        args = [bin_path, data_path, alg, mode]
    elif mode in SPRINT1_BIN:
        bin_path = SPRINT1_BIN[mode]
        args = [bin_path, data_path, alg, mode]
    else:
        return {'error': 'Modo no soportado'}
    try:
        result = subprocess.run(args, capture_output=True, text=True, timeout=60)
        output = result.stdout + result.stderr
        return {'output': output, 'returncode': result.returncode}
    except Exception as e:
        return {'error': str(e)}

def get_sorted_students(alg, mode, n=10, dataset='5000'):
    # Solo mostrar muestra ordenada para el dataset pequeño
    if dataset != '5000':
        return [], []
    with open(DATA_FILES[dataset], newline='') as csvfile:
        reader = csv.reader(csvfile)
        headers = next(reader)
        students = list(reader)
    def student_key(row):
        promedio = float(row[2])
        creditos = int(row[3])
        condicion = row[4]
        ingreso = int(row[5])
        return (-promedio, -creditos, condicion, ingreso)
    if alg == 'ms' or alg == 'qs':
        students_sorted = sorted(students, key=student_key)
    else:
        students_sorted = students
    return headers, students_sorted[:n]

# Utilidad para extraer el tiempo de la salida del binario
def extract_time(output):
    match = re.search(r"Tiempo\s+([0-9.]+)\s*ms", output)
    if match:
        return float(match.group(1))
    return None

@app.route('/', methods=['GET'])
def index():
    headers, students = get_sample_students(10, '5000')
    return render_template('index.html', headers=headers, students=students, history=history, sorted_headers=headers, sorted_students=[], dataset='5000')

@app.route('/run', methods=['POST'])
def run():
    data = request.json
    alg = data.get('alg')
    n = data.get('n', 10)
    dataset = data.get('dataset', '5000')
    # Ejecutar todos los modos para comparar
    modos = ['seq', 'omp', 'cuda']
    resultados = {}
    tiempos = {}
    for mode in modos:
        if (mode == 'cuda' and 'cuda' not in SPRINT2_BIN) or (mode != 'cuda' and mode not in SPRINT1_BIN):
            continue
        result = run_sort(alg, mode, n, dataset)
        resultados[mode] = result
        tiempos[mode] = extract_time(result.get('output', ''))
    # Calcular speedup
    speedups = {}
    if tiempos.get('seq'):
        for mode in ['omp', 'cuda']:
            if tiempos.get(mode):
                speedups[mode] = round(tiempos['seq'] / tiempos[mode], 2)
    # Respuesta
    sorted_headers, sorted_students = get_sorted_students(alg, 'seq', n, dataset)
    return jsonify({
        'resultados': resultados,
        'tiempos': tiempos,
        'speedups': speedups,
        'sorted_headers': sorted_headers,
        'sorted_students': sorted_students
    })

@app.route('/sample', methods=['GET'])
def sample():
    dataset = request.args.get('dataset', '5000')
    headers, students = get_sample_students(10, dataset)
    return jsonify({'headers': headers, 'students': students})

if __name__ == '__main__':
    app.run(debug=True)
