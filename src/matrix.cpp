#include "matrix/matrix.hpp"

#include <iomanip>
#include <ostream>

namespace matrix {

Matrix::Matrix(std::size_t rows, std::size_t cols)
    : rows_(rows), cols_(cols), data_(rows * cols, 0.0) {}

Matrix::Matrix(std::size_t rows, std::size_t cols, std::vector<double> data)
    : rows_(rows), cols_(cols), data_(std::move(data)) {
    if (data_.size() != rows_ * cols_) {
        throw std::invalid_argument("matrix data size does not match rows * cols");
    }
}

std::size_t Matrix::rows() const noexcept {
    return rows_;
}

std::size_t Matrix::cols() const noexcept {
    return cols_;
}

double& Matrix::operator()(std::size_t row, std::size_t col) {
    if (row >= rows_ || col >= cols_) {
        throw std::out_of_range("matrix index out of range");
    }
    return data_[row * cols_ + col];
}

double Matrix::operator()(std::size_t row, std::size_t col) const {
    if (row >= rows_ || col >= cols_) {
        throw std::out_of_range("matrix index out of range");
    }
    return data_[row * cols_ + col];
}

const std::vector<double>& Matrix::data() const noexcept {
    return data_;
}

Matrix multiply(const Matrix& lhs, const Matrix& rhs) {
    if (lhs.cols() != rhs.rows()) {
        throw std::invalid_argument("matrix dimensions are not compatible for multiplication");
    }

    Matrix result(lhs.rows(), rhs.cols());

    for (std::size_t i = 0; i < lhs.rows(); ++i) {
        for (std::size_t k = 0; k < lhs.cols(); ++k) {
            const double lhs_value = lhs(i, k);

            for (std::size_t j = 0; j < rhs.cols(); ++j) {
                result(i, j) += lhs_value * rhs(k, j);
            }
        }
    }

    return result;
}

std::ostream& operator<<(std::ostream& os, const Matrix& m) {
    for (std::size_t i = 0; i < m.rows(); ++i) {
        for (std::size_t j = 0; j < m.cols(); ++j) {
            os << std::setw(8) << m(i, j);
        }
        os << '\n';
    }

    return os;
}

}  // namespace matrix