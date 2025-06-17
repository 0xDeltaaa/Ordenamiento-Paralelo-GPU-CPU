#pragma once
#include <chrono>

using clock_point = std::chrono::steady_clock::time_point;

inline clock_point tic()  { return std::chrono::steady_clock::now(); }
inline double      toc(clock_point t0){
    return std::chrono::duration<double,std::milli>(
               std::chrono::steady_clock::now()-t0).count();
}
