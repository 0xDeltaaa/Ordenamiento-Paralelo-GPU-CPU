#include "../../utils/student.hpp"
#include <algorithm>
#include <vector>

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

static void quick_seq(Student* first,Student* last){
    if(last-first < 2048){ std::sort(first,last); return; }
    Student* p = partition(first,last);
    quick_seq(first,p+1);
    quick_seq(p+1,last);
}

void quick_sort_seq(std::vector<Student>& v){
    quick_seq(v.data(),v.data()+v.size());
}
