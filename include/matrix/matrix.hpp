#pragma once

#include <cstddef>
#include <iosfwd>
#include <stdexcept>
#include <vector>

namespace matrix {

class Matrix {
public:
    Matrix(std::size_t rows, std::size_t cols);
    Matrix(std::size_t rows, std::size_t cols, std::vector<double> data);

    std::size_t rows() const noexcept;
    std::size_t cols() const noexcept;

    double& operator()(std::size_t row, std::size_t col);
    double operator()(std::size_t row, std::size_t col) const;

    const std::vector<double>& data() const noexcept;

private:
    std::size_t rows_{0};
    std::size_t cols_{0};
    std::vector<double> data_;
};

Matrix multiply(const Matrix& lhs, const Matrix& rhs);

std::ostream& operator<<(std::ostream& os, const Matrix& m);

}  // namespace matrix