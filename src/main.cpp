#include "matrix/matrix.hpp"
#include <fmt/format.h>
#include <fmt/color.h>
#include <iostream>

int main() {
    const matrix::Matrix a{
        2,
        3,
        {
            1.0, 2.0, 3.0,
            4.0, 5.0, 6.0,
        }
    };

    const matrix::Matrix b{
        3,
        2,
        {
            7.0,  8.0,
            9.0,  10.0,
            11.0, 12.0,
        }
    };

    const matrix::Matrix c = matrix::multiply(a, b);

    fmt::print(fmt::fg(fmt::color::blue) | fmt::emphasis::bold, "A * B = \n");
    std::cout << c;


    return 0;
}