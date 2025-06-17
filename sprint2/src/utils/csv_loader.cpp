#include "csv_loader.hpp"
#include <fstream>
#include <sstream>
#include <algorithm>   // std::replace

std::vector<Student> load_csv(const std::string& path)
{
    std::ifstream in(path);
    if (!in) throw std::runtime_error("No se pudo abrir " + path);

    std::string line;
    std::getline(in, line);            // descarta cabecera

    std::vector<Student> v;
    v.reserve(8192);

    while (std::getline(in, line)) {
        if (line.empty()) continue;    // salta líneas en blanco

        std::stringstream ss(line);
        std::string tok;
        Student s{};

        /* 1) DNI */
        std::getline(ss, tok, ',');
        s.dni = std::stoul(tok);

        /* 2) nombre_completo — lo ignoramos */
        std::getline(ss, tok, ',');

        /* 3) promedio_ponderado */
        std::getline(ss, tok, ',');
        std::replace(tok.begin(), tok.end(), ',', '.'); // coma → punto dec.
        s.promedio = std::stof(tok);

        /* 4) creditos_aprobados */
        std::getline(ss, tok, ',');
        s.creditos = static_cast<uint16_t>(std::stoi(tok));

        /* 5) facultad — lo ignoramos */
        std::getline(ss, tok, ',');

        /* 6) anio_ingreso */
        std::getline(ss, tok, ',');
        s.ingreso = static_cast<uint16_t>(std::stoi(tok));

        /* 7) condicion_socioeconomica  → 0 Alto | 1 Medio | 2 Bajo */
        std::getline(ss, tok, ',');
        if      (tok == "Alto")  s.condicion = 0;
        else if (tok == "Medio") s.condicion = 1;
        else                     s.condicion = 2;   // Bajo u otro

        v.emplace_back(s);
    }
    return v;
}

