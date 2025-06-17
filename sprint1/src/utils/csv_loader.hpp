#pragma once
#include "student.hpp"
#include <vector>
#include <string>

std::vector<Student> load_csv(const std::string& path);
