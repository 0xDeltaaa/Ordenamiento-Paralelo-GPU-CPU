#include "../../utils/student.hpp"
#include <algorithm>
#include <vector>
#include <omp.h>

static Student* partition(Student* first,Student* last){
    Student pivot = *(first+(last-first)/2);
    Student* i=first; Student* j=last-1;
    while(true){
        while(*i < pivot) ++i;
        while(pivot < *j) --j;
        if(i>=j) return j;
        std::swap(*i,*j); ++i; --j;
    }
}

static void quick_omp(Student* first,Student* last,int depth){
    if(last-first < (1<<15)){ std::sort(first,last); return; }
    Student* p = partition(first,last);
    #pragma omp task if(depth<4)
        quick_omp(first,p+1,depth+1);
    #pragma omp task if(depth<4)
        quick_omp(p+1,last,depth+1);
}

void quick_sort_omp(std::vector<Student>& v){
    #pragma omp parallel
    #pragma omp single
        quick_omp(v.data(),v.data()+v.size(),0);
}
