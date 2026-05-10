#include "matrix/matrix.hpp"

#include <gtest/gtest.h>

TEST(MatrixTest, ConstructMatrix) {
    const matrix::Matrix m{
        2,
        2,
        {
            1.0, 2.0,
            3.0, 4.0,
        }
    };

    EXPECT_EQ(m.rows(), 2);
    EXPECT_EQ(m.cols(), 2);
    EXPECT_DOUBLE_EQ(m(0, 0), 1.0);
    EXPECT_DOUBLE_EQ(m(0, 1), 2.0);
    EXPECT_DOUBLE_EQ(m(1, 0), 3.0);
    EXPECT_DOUBLE_EQ(m(1, 1), 4.0);
}

TEST(MatrixTest, MultiplyTwoByTwo) {
    const matrix::Matrix a{
        2,
        2,
        {
            1.0, 2.0,
            3.0, 4.0,
        }
    };

    const matrix::Matrix b{
        2,
        2,
        {
            5.0, 6.0,
            7.0, 8.0,
        }
    };

    const matrix::Matrix c = matrix::multiply(a, b);

    EXPECT_DOUBLE_EQ(c(0, 0), 19.0);
    EXPECT_DOUBLE_EQ(c(0, 1), 22.0);
    EXPECT_DOUBLE_EQ(c(1, 0), 43.0);
    EXPECT_DOUBLE_EQ(c(1, 1), 50.0);
}

TEST(MatrixTest, MultiplyTwoByThreeAndThreeByTwo) {
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

    EXPECT_EQ(c.rows(), 2);
    EXPECT_EQ(c.cols(), 2);

    EXPECT_DOUBLE_EQ(c(0, 0), 58.0);
    EXPECT_DOUBLE_EQ(c(0, 1), 64.0);
    EXPECT_DOUBLE_EQ(c(1, 0), 139.0);
    EXPECT_DOUBLE_EQ(c(1, 1), 154.0);
}

TEST(MatrixTest, InvalidDimensionsThrow) {
    const matrix::Matrix a{2, 3};
    const matrix::Matrix b{2, 2};

    EXPECT_THROW(
        matrix::multiply(a, b),
        std::invalid_argument
    );
}

TEST(MatrixTest, OutOfRangeThrows) {
    matrix::Matrix m{2, 2};

    EXPECT_THROW(m(2, 0), std::out_of_range);
    EXPECT_THROW(m(0, 2), std::out_of_range);
}