#pragma once
#include <cstdint>
#include <ostream>

/* -------------  Estructura de un registro ------------------
   Columnas esperadas en estudiantes_5000.csv:
   dni,promedio,creditos,ingreso,condicion
------------------------------------------------------------*/
struct Student {
    uint32_t dni;       //  8 – 9 dígitos
    float    promedio;  //  0 – 20   (↓ ordenamos descendente)
    uint16_t creditos;  //  0 – 240  (↓ descendente)
    uint16_t ingreso;   //  2010 – 2025  (↑ ascendente)
    uint8_t  condicion; //  0 = alta, 1 = media, 2 = baja  (↑ ascendente)
};

/* Orden total: primero mejor promedio, luego +créditos,
   luego condición socio-económica y finalmente año de ingreso. */
inline bool operator<(const Student& a,const Student& b){
    if (a.promedio != b.promedio)   return a.promedio > b.promedio;
    if (a.creditos != b.creditos)   return a.creditos > b.creditos;
    if (a.condicion!= b.condicion)  return a.condicion< b.condicion;
    return a.ingreso < b.ingreso;
}
