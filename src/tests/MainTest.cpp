#include <gtest/gtest.h>

extern "C" {
    #include <btc/ecc.h>
    }

/**
 * main() for Google Test. 
 * If you already have a testing entry point elsewhere,
 * you can omit or adjust this. 
 */
int main(int argc, char **argv) {
    testing::InitGoogleTest(&argc, argv);
    btc_ecc_start();
    int result = RUN_ALL_TESTS();
    btc_ecc_stop();
    return result;
}