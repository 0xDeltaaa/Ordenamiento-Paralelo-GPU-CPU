#include "../../utils/student.hpp"
#include <algorithm>
#include <vector>

static void merge_seq(Student* first,Student* last,
                      std::vector<Student>& buf){
    std::size_t n = last-first;
    if(n < 2048){ std::sort(first,last); return; }

    Student* mid = first + n/2;
    merge_seq(first,mid,buf);
    merge_seq(mid,last,buf);

    std::merge(first,mid,mid,last,buf.begin(),std::less<Student>());
    std::copy(buf.begin(),buf.begin()+n,first);
}

void merge_sort_seq(std::vector<Student>& v){
    std::vector<Student> buf(v.size());
    merge_seq(v.data(),v.data()+v.size(),buf);
}
