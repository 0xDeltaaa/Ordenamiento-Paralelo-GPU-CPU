#include "../../utils/student.hpp"
#include <thrust/device_vector.h>
#include <thrust/sort.h>

struct StudentComp {
    __host__ __device__
    bool operator()(const Student& a, const Student& b) const {
        if (a.promedio != b.promedio)   return a.promedio > b.promedio;
        if (a.creditos != b.creditos)   return a.creditos > b.creditos;
        if (a.condicion!= b.condicion)  return a.condicion < b.condicion;
        return a.ingreso < b.ingreso;
    }
};

void quick_sort_gpu(std::vector<Student>& h_vec)
{
    thrust::device_vector<Student> d = h_vec;
    thrust::sort(d.begin(), d.end(), StudentComp{});
    thrust::copy(d.begin(), d.end(), h_vec.begin());
}

