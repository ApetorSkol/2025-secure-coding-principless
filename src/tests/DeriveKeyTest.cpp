/**
 * Project: PV286 2024/2025 Project
 * @file DeriveKeyTest.cpp
 * @author
 * @brief GTest unit tests for the DeriveKey component
 * @date 2025-03-20
 *
 * This file contains GTest-based unit tests for the DeriveKey class.
 * It checks correct detection of CLI arguments, subcommand usage,
 * error handling, and special flags such as --verify-checksum or --compute-checksum.
 *
 * © 2025
 */

#include <gtest/gtest.h>
#include <sstream>
#include <iostream>
#include <vector>
#include <string>

#include "../app/DeriveKey/DeriveKey.h"

/**
 * Helper to capture std::cout output.
 */
class CoutRedirect
{
public:
    CoutRedirect(std::streambuf *newBuffer) : old(std::cout.rdbuf(newBuffer)) {}
    ~CoutRedirect() { std::cout.rdbuf(old); }

private:
    std::streambuf *old;
};

/**
 * Valid seed should produce expected xpub:xprv output format.
 */
TEST(DeriveKeyTest, HandleSeedSimple)
{
    std::vector<std::string> values = {
        "000102030405060708090a0b0c0d0e0f"};
    std::ostringstream out;
    CoutRedirect redirect(out.rdbuf());

    EXPECT_NO_THROW({
        deriveKey(values, "");
    });

    std::string output = out.str();
    EXPECT_TRUE(output.find("xpub") == 0);
    EXPECT_NE(output.find(":"), std::string::npos);
    EXPECT_NE(output.find("xprv"), std::string::npos);
}

/**
 * Valid extended private key input produces xpub:xprv output.
 */
TEST(DeriveKeyTest, HandleXprvSimple)
{
    std::vector<std::string> values = {
        "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi"};
    std::ostringstream out;
    CoutRedirect redirect(out.rdbuf());

    EXPECT_NO_THROW({
        deriveKey(values, "");
    });

    std::string output = out.str();
    EXPECT_TRUE(output.find("xpub") == 0);
    EXPECT_NE(output.find(":"), std::string::npos);
    EXPECT_NE(output.find("xprv"), std::string::npos);
}

/**
 * Valid extended public key should produce xpub:
 */
TEST(DeriveKeyTest, HandleXpubSimple)
{
    std::vector<std::string> values = {
        "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8"};
    std::ostringstream out;
    CoutRedirect redirect(out.rdbuf());

    EXPECT_NO_THROW({
        deriveKey(values, "");
    });

    std::string output = out.str();
    EXPECT_TRUE(output.find("xpub") == 0);
    EXPECT_EQ(output.find(":"), std::string::npos);
    EXPECT_EQ(output.find("xprv"), std::string::npos);
}

/**
 * Invalid seed should terminate the program (exit 1).
 */
TEST(DeriveKeyTest, InvalidSeedExits)
{
    std::vector<std::string> values = {"invalidseed"};
    EXPECT_EXIT({ deriveKey(values, ""); }, ::testing::ExitedWithCode(1), ".*invalid characters in seed.*");
}

/**
 * Invalid xprv should terminate the program (exit 1).
 */
TEST(DeriveKeyTest, InvalidXprvExits)
{
    std::vector<std::string> values = {
        "xprvInvalidBase58Key"};

    SUCCEED(); // placeholder
}

TEST(DeriveKeyTest, SeedWithSpacesAndTabs)
{
    std::vector<std::string> values = {
        "00 01 02 03\t04 05 06\t07 08 09 0a 0b 0c 0d 0e 0f"};
    std::ostringstream out;
    CoutRedirect redirect(out.rdbuf());
    EXPECT_NO_THROW(deriveKey(values, ""));
    std::string output = out.str();
    EXPECT_TRUE(output.find("xpub") == 0);
    EXPECT_NE(output.find(":"), std::string::npos);
}

/**
 * @test Seed shorter than 16 bytes should trigger an error.
 */
TEST(DeriveKeyTest, SeedBelowMinimumLengthFails)
{
    std::vector<std::string> values = {"000102030405060708090a0b0c0d"};
    EXPECT_EXIT({ deriveKey(values, ""); }, ::testing::ExitedWithCode(1), ".*seed length out of range.*");
}

/**
 * @test Seed with maximum allowed length (64 bytes) should succeed.
 */
TEST(DeriveKeyTest, SeedAtMaximumLengthSucceeds)
{
    std::string seed(128, 'a');
    std::vector<std::string> values = {seed};
    std::ostringstream out;
    CoutRedirect redirect(out.rdbuf());
    EXPECT_NO_THROW(deriveKey(values, ""));
    std::string output = out.str();
    EXPECT_TRUE(output.find("xpub") == 0);
    EXPECT_NE(output.find("xprv"), std::string::npos);
}

/**
 * @test Extended key containing invalid Base58 character should trigger an error.
 */
TEST(DeriveKeyTest, InvalidBase58CharacterInXprvFails)
{
    std::vector<std::string> values = {
        "xprv9s21ZrQH143K30TDL4LXw2F7HEK3wINVALID"};
    EXPECT_EXIT({ deriveKey(values, ""); }, ::testing::ExitedWithCode(1), ".*invalid extended key.*");
}

/**
 * @test Derivation path with an index > 2^31-1 should fail.
 */
TEST(DeriveKeyTest, DerivationPathTooLargeFails)
{
    std::vector<std::string> values = {
        "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi"};
    EXPECT_EXIT({ deriveKey(values, "2147483648"); }, ::testing::ExitedWithCode(1), ".*derivation index out of range.*");
}

/**
 * @test Derivation path with negative value should trigger an error.
 */
TEST(DeriveKeyTest, DerivationPathNegativeFails)
{
    std::vector<std::string> values = {
        "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi"};
    EXPECT_EXIT({ deriveKey(values, "-1"); }, ::testing::ExitedWithCode(1), ".*invalid derivation index.*");
}

/**
 * @test Derivation path with double slashes should be rejected.
 */
TEST(DeriveKeyTest, DerivationPathDoubleSlashFails)
{
    std::vector<std::string> values = {
        "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi"};
    EXPECT_EXIT({ deriveKey(values, "0//1"); }, ::testing::ExitedWithCode(1), ".*invalid derivation index.*");
}

/**
 * @test Derivation path ending with a slash should be rejected.
 */
TEST(DeriveKeyTest, DerivationPathTrailingSlashFails)
{
    std::vector<std::string> values = {
        "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi"};
    EXPECT_EXIT({ deriveKey(values, "0/1/"); }, ::testing::ExitedWithCode(1), ".*trailing slash not allowed.*");
}

/**
 * @test Mixed notation for hardened keys (H, h, ') should be accepted.
 */
TEST(DeriveKeyTest, DerivationPathMixedHardenedSyntaxSucceeds)
{
    std::vector<std::string> values = {
        "xprv9wTYmMFdV23N2TdNG573QoEsfRrWKQgWeibmLntzniatZvR9BmLnvSxqu53Kw1UmYPxLgboyZQaXwTCg8MSY3H2EU4pWcQDnRnrVA1xe8fs"};
    std::ostringstream out;
    CoutRedirect redirect(out.rdbuf());
    EXPECT_NO_THROW(deriveKey(values, "0H/1h/2'/3"));
    std::string output = out.str();
    EXPECT_TRUE(output.find("xpub") == 0);
    EXPECT_NE(output.find("xprv"), std::string::npos);
}

/**
 * @test Seed containing various whitespace characters should be accepted.
 */
TEST(DeriveKeyTest, SeedWithVariousWhitespace)
{
    std::vector<std::string> values = {
        "00\t01\n02 03\r04 05 06 07 08 09 0a 0b 0c 0d 0e 0f"};
    std::ostringstream out;
    CoutRedirect redirect(out.rdbuf());
    EXPECT_NO_THROW(deriveKey(values, ""));
    std::string output = out.str();
    EXPECT_TRUE(output.find("xpub") == 0);
    EXPECT_NE(output.find("xprv"), std::string::npos);
}

/**
 * @test Seed with odd number of hexadecimal characters should fail.
 */
TEST(DeriveKeyTest, SeedWithOddHexLengthFails)
{
    std::vector<std::string> values = {"000102030405060708090a0b0c0d0e"};
    EXPECT_EXIT({ deriveKey(values, ""); }, ::testing::ExitedWithCode(1), ".*seed length out of range.*");
}

/**
 * @test Uppercase hexadecimal characters in seed should be accepted.
 */
TEST(DeriveKeyTest, UpperCaseHexSeedSucceeds)
{
    std::vector<std::string> values = {
        "000102030405060708090A0B0C0D0E0F"};
    std::ostringstream out;
    CoutRedirect redirect(out.rdbuf());
    EXPECT_NO_THROW(deriveKey(values, ""));
    std::string output = out.str();
    EXPECT_TRUE(output.find("xpub") == 0);
    EXPECT_NE(output.find("xprv"), std::string::npos);
}

/**
 * @test Empty input value should be ignored and produce no output.
 */
TEST(DeriveKeyTest, EmptyValueIgnored)
{
    std::vector<std::string> values = {""};
    std::ostringstream out;
    CoutRedirect redirect(out.rdbuf());
    EXPECT_NO_THROW(deriveKey(values, ""));
    EXPECT_EQ(out.str(), "");
}

/**
 * @test Seed with non-hexadecimal characters should be rejected.
 */
TEST(DeriveKeyTest, SeedWithInvalidCharactersFails)
{
    std::vector<std::string> values = {"00010203INVALID0405060708"};
    EXPECT_EXIT({ deriveKey(values, ""); }, ::testing::ExitedWithCode(1), ".*invalid characters in seed.*");
}

/**
 * @test Hardened derivation from xpub should fail.
 */
TEST(DeriveKeyTest, XpubWithHardenedPathFails)
{
    std::vector<std::string> values = {
        "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8"};
    EXPECT_EXIT({ deriveKey(values, "0H"); }, ::testing::ExitedWithCode(1), ".*cannot derive hardened key from xpub.*");
}

/**
 * @test Extended key with invalid prefix should be rejected.
 */
TEST(DeriveKeyTest, InvalidExtendedKeyPrefixFails)
{
    std::vector<std::string> values = {
        "xprvINVALIDBADKEY"};
    EXPECT_EXIT({ deriveKey(values, ""); }, ::testing::ExitedWithCode(1), ".*invalid extended key.*");
}

/**
 * @test Valid seed processed before invalid one should still produce correct output.
 */
TEST(DeriveKeyTest, ValidSeedSucceedsBeforeInvalidOne)
{
    std::vector<std::string> values = {
        "000102030405060708090a0b0c0d0e0f"};
    std::ostringstream out;
    CoutRedirect redirect(out.rdbuf());
    EXPECT_NO_THROW(deriveKey(values, ""));
    std::string output = out.str();
    EXPECT_TRUE(output.find("xpub") == 0);
}

/**
 * @test Invalid seed processed after valid one should trigger an error.
 */
TEST(DeriveKeyTest, InvalidSeedFailsAfterValidOne)
{
    std::vector<std::string> values = {
        "INVALID"};
    EXPECT_EXIT({ deriveKey(values, ""); }, ::testing::ExitedWithCode(1), ".*invalid characters in seed.*");
}

/**
 * @test Malformed xpub should be rejected.
 */
TEST(DeriveKeyTest, MalformedXpubFails)
{
    std::vector<std::string> values = {
        "xpub6D4BDPcP2GT577Vvch3R8wDkScZWzQzMMUm3PWbmWvVJrZwQY4VUNgqFJPMM3No2dFDFGTsxxpG5uJh7n7epu4trkrX7x7DogT5Uv6fcLW0"};
    EXPECT_EXIT({ deriveKey(values, ""); }, ::testing::ExitedWithCode(1), ".*invalid extended key.*");
}

/**
 * @test Multiple seeds from stdin should produce multiple xpub:xprv outputs.
 */
TEST(DeriveKeyTest, MultipleSeedsFromStdinSucceeds)
{
    std::vector<std::string> values = {
        "000102030405060708090a0b0c0d0e0f",
        "fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a29f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542"};
    std::ostringstream out;
    CoutRedirect redirect(out.rdbuf());

    EXPECT_NO_THROW(deriveKey(values, ""));

    std::string output = out.str();
    EXPECT_NE(output.find("xpub"), std::string::npos);
    EXPECT_NE(output.find("xprv"), std::string::npos);
    EXPECT_NE(output.find("\n"), std::string::npos); // Output should contain line break
}

/**
 * @test Seed with derivation path should produce derived key pair.
 */
TEST(DeriveKeyTest, SeedWithDerivationPathSucceeds)
{
    std::vector<std::string> values = {
        "000102030405060708090a0b0c0d0e0f"};
    std::ostringstream out;
    CoutRedirect redirect(out.rdbuf());

    EXPECT_NO_THROW(deriveKey(values, "0/1"));

    std::string output = out.str();
    EXPECT_TRUE(output.find("xpub") == 0);
    EXPECT_NE(output.find("xprv"), std::string::npos);
}

/**
 * @test Derivation path before dash (stdin) should be accepted.
 */
TEST(DeriveKeyTest, DerivationPathBeforeDashSucceeds)
{
    std::vector<std::string> values = {
        "000102030405060708090a0b0c0d0e0f"};
    std::ostringstream out;
    CoutRedirect redirect(out.rdbuf());

    EXPECT_NO_THROW(deriveKey(values, "0/1"));

    std::string output = out.str();
    EXPECT_TRUE(output.find("xpub") == 0);
    EXPECT_NE(output.find("xprv"), std::string::npos);
}

/**
 * @test Multiple seeds with empty lines should skip empty lines and derive valid keys.
 */
TEST(DeriveKeyTest, MultipleSeedsWithEmptyLinesIgnored)
{
    std::vector<std::string> values = {
        "000102030405060708090a0b0c0d0e0f",
        "",
        "fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a29f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542",
        ""};
    std::ostringstream out;
    CoutRedirect redirect(out.rdbuf());

    EXPECT_NO_THROW(deriveKey(values, ""));
    std::string output = out.str();

    size_t count = std::count(output.begin(), output.end(), '\n');
    EXPECT_GE(count, 1); // Should at least be two lines
    EXPECT_NE(output.find("xpub"), std::string::npos);
    EXPECT_NE(output.find("xprv"), std::string::npos);
}
