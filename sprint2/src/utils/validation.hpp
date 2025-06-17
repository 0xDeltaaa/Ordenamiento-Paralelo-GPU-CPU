#pragma once
#include "student.hpp"
#include <vector>
#include <algorithm>

inline bool is_sorted(const std::vector<Student>& v){
    return std::is_sorted(v.begin(), v.end());
}
inline bool equal_sorted(const std::vector<Student>& a,
                         const std::vector<Student>& b){
    return std::equal(a.begin(),a.end(),b.begin(),b.end(),
           [](auto&x,auto&y){ return !(x<y) && !(y<x); });
}
