#include <gtest/gtest.h>

/**
 * main() for Google Test. 
 * If you already have a testing entry point elsewhere,
 * you can omit or adjust this. 
 */
int main(int argc, char **argv) {
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}