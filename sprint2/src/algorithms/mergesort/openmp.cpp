#include "../../utils/student.hpp"
#include <algorithm>
#include <vector>
#include <omp.h>

static void merge_omp(Student* first,Student* last,
                      Student* buf,int depth){
    std::size_t n = last-first;
    if(n < (1<<15)){ std::sort(first,last); return; }

    Student* mid = first + n/2;

    #pragma omp task if(depth<4)
        merge_omp(first,mid,buf,depth+1);
    #pragma omp task if(depth<4)
        merge_omp(mid,last,buf+(mid-first),depth+1);
    #pragma omp taskwait

    std::merge(first,mid,mid,last,buf,std::less<Student>());
    std::copy(buf,buf+n,first);
}

void merge_sort_omp(std::vector<Student>& v){
    std::vector<Student> buf(v.size());
    #pragma omp parallel
    #pragma omp single
        merge_omp(v.data(),v.data()+v.size(),buf.data(),0);
}
