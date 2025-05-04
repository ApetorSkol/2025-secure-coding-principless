/**
 * Project: PV286 2024/2025 Project
 * @file ScriptExpressionTest.cpp
 * @author Matej Slivka
 * @brief GTest unit tests for the ScriptExpression component
 * @date 2025-03-20
 *
 * This file contains GTest-based unit tests for the ScriptExpression class. 
 * It checks correct detection of CLI arguments, subcommand usage, 
 * error handling, and special flags such as --verify-checksum or --compute-checksum.
 *
 * © 2025
 */

#include <gtest/gtest.h>
#include "../app/ArgParser/ArgParser.h"
#include "../app/ScriptExpression/ScriptExpression.h"


/**
 * Tests for multiple length possibilities for --compute-checksum flag described in assignment.
 */
TEST(ScriptExpressionTest, ComputeChecksum0) {
    const char *argv[] = {"bip380", "script-expression", "--compute-checksum", "raw(deadbeef)#89f8spxm"};
    int argc = 4;
    ArgParser argParser;
    argParser.loadArguments(argc, const_cast<char **>(argv));
    argParser.parse();

    std::stringstream buffer;
    std::streambuf *sbuf = std::cout.rdbuf(); // save old buffer
    std::cout.rdbuf(buffer.rdbuf()); // redirect std::cout to buffer

    ScriptExpression scriptExpression(argParser.getArgValues(), argParser.getComputeChecksumFlag(), argParser.getVerifyChecksumFlag());
    scriptExpression.parse();

    std::string output = buffer.str(); // capture the output
    std::cout.rdbuf(sbuf); // reset to standard output again
    // Check the output
    EXPECT_EQ(output, "raw(deadbeef)#89f8spxm\n");
}

TEST(ScriptExpressionTest, ComputeChecksum1) {
    const char *argv[] = {"bip380", "script-expression", "--compute-checksum", "raw(deadbeef)#89f8spx"};
    int argc = 4;
    ArgParser argParser;
    argParser.loadArguments(argc, const_cast<char **>(argv));
    argParser.parse();

    std::stringstream buffer;
    std::streambuf *sbuf = std::cout.rdbuf(); // save old buffer
    std::cout.rdbuf(buffer.rdbuf()); // redirect std::cout to buffer

    ScriptExpression scriptExpression(argParser.getArgValues(), argParser.getComputeChecksumFlag(), argParser.getVerifyChecksumFlag());
    scriptExpression.parse();

    std::string output = buffer.str(); // capture the output
    std::cout.rdbuf(sbuf); // reset to standard output again
    // Check the output
    EXPECT_EQ(output, "raw(deadbeef)#89f8spxm\n");
}

TEST(ScriptExpressionTest, ComputeChecksum2) {
    const char *argv[] = {"bip380", "script-expression", "--compute-checksum", "raw(deadbeef)#89f8sp"};
    int argc = 4;
    ArgParser argParser;
    argParser.loadArguments(argc, const_cast<char **>(argv));
    argParser.parse();

    std::stringstream buffer;
    std::streambuf *sbuf = std::cout.rdbuf(); // save old buffer
    std::cout.rdbuf(buffer.rdbuf()); // redirect std::cout to buffer

    ScriptExpression scriptExpression(argParser.getArgValues(), argParser.getComputeChecksumFlag(), argParser.getVerifyChecksumFlag());
    scriptExpression.parse();

    std::string output = buffer.str(); // capture the output
    std::cout.rdbuf(sbuf); // reset to standard output again
    // Check the output
    EXPECT_EQ(output, "raw(deadbeef)#89f8spxm\n");
}

TEST(ScriptExpressionTest, ComputeChecksum3) {
    const char *argv[] = {"bip380", "script-expression", "--compute-checksum", "raw(deadbeef)#89f8s"};
    int argc = 4;
    ArgParser argParser;
    argParser.loadArguments(argc, const_cast<char **>(argv));
    argParser.parse();

    std::stringstream buffer;
    std::streambuf *sbuf = std::cout.rdbuf(); // save old buffer
    std::cout.rdbuf(buffer.rdbuf()); // redirect std::cout to buffer

    ScriptExpression scriptExpression(argParser.getArgValues(), argParser.getComputeChecksumFlag(), argParser.getVerifyChecksumFlag());
    scriptExpression.parse();

    std::string output = buffer.str(); // capture the output
    std::cout.rdbuf(sbuf); // reset to standard output again
    // Check the output
    EXPECT_EQ(output, "raw(deadbeef)#89f8spxm\n");
}

TEST(ScriptExpressionTest, ComputeChecksum4) {
    const char *argv[] = {"bip380", "script-expression", "--compute-checksum", "raw(deadbeef)#89f8"};
    int argc = 4;
    ArgParser argParser;
    argParser.loadArguments(argc, const_cast<char **>(argv));
    argParser.parse();

    std::stringstream buffer;
    std::streambuf *sbuf = std::cout.rdbuf(); // save old buffer
    std::cout.rdbuf(buffer.rdbuf()); // redirect std::cout to buffer

    ScriptExpression scriptExpression(argParser.getArgValues(), argParser.getComputeChecksumFlag(), argParser.getVerifyChecksumFlag());
    scriptExpression.parse();

    std::string output = buffer.str(); // capture the output
    std::cout.rdbuf(sbuf); // reset to standard output again
    // Check the output
    EXPECT_EQ(output, "raw(deadbeef)#89f8spxm\n");
}

TEST(ScriptExpressionTest, ComputeChecksum5) {
    const char *argv[] = {"bip380", "script-expression", "--compute-checksum", "raw(deadbeef)#89f"};
    int argc = 4;
    ArgParser argParser;
    argParser.loadArguments(argc, const_cast<char **>(argv));
    argParser.parse();

    std::stringstream buffer;
    std::streambuf *sbuf = std::cout.rdbuf(); // save old buffer
    std::cout.rdbuf(buffer.rdbuf()); // redirect std::cout to buffer

    ScriptExpression scriptExpression(argParser.getArgValues(), argParser.getComputeChecksumFlag(), argParser.getVerifyChecksumFlag());
    scriptExpression.parse();

    std::string output = buffer.str(); // capture the output
    std::cout.rdbuf(sbuf); // reset to standard output again
    // Check the output
    EXPECT_EQ(output, "raw(deadbeef)#89f8spxm\n");
}

TEST(ScriptExpressionTest, ComputeChecksum6) {
    const char *argv[] = {"bip380", "script-expression", "--compute-checksum", "raw(deadbeef)#89"};
    int argc = 4;
    ArgParser argParser;
    argParser.loadArguments(argc, const_cast<char **>(argv));
    argParser.parse();

    std::stringstream buffer;
    std::streambuf *sbuf = std::cout.rdbuf(); // save old buffer
    std::cout.rdbuf(buffer.rdbuf()); // redirect std::cout to buffer

    ScriptExpression scriptExpression(argParser.getArgValues(), argParser.getComputeChecksumFlag(), argParser.getVerifyChecksumFlag());
    scriptExpression.parse();

    std::string output = buffer.str(); // capture the output
    std::cout.rdbuf(sbuf); // reset to standard output again
    // Check the output
    EXPECT_EQ(output, "raw(deadbeef)#89f8spxm\n");
}

TEST(ScriptExpressionTest, ComputeChecksum7) {
    const char *argv[] = {"bip380", "script-expression", "--compute-checksum", "raw(deadbeef)#89"};
    int argc = 4;
    ArgParser argParser;
    argParser.loadArguments(argc, const_cast<char **>(argv));
    argParser.parse();

    std::stringstream buffer;
    std::streambuf *sbuf = std::cout.rdbuf(); // save old buffer
    std::cout.rdbuf(buffer.rdbuf()); // redirect std::cout to buffer

    ScriptExpression scriptExpression(argParser.getArgValues(), argParser.getComputeChecksumFlag(), argParser.getVerifyChecksumFlag());
    scriptExpression.parse();

    std::string output = buffer.str(); // capture the output
    std::cout.rdbuf(sbuf); // reset to standard output again
    // Check the output
    EXPECT_EQ(output, "raw(deadbeef)#89f8spxm\n");
}

TEST(ScriptExpressionTest, ComputeChecksum8) {
    const char *argv[] = {"bip380", "script-expression", "--compute-checksum", "raw(deadbeef)#8"};
    int argc = 4;
    ArgParser argParser;
    argParser.loadArguments(argc, const_cast<char **>(argv));
    argParser.parse();

    std::stringstream buffer;
    std::streambuf *sbuf = std::cout.rdbuf(); // save old buffer
    std::cout.rdbuf(buffer.rdbuf()); // redirect std::cout to buffer

    ScriptExpression scriptExpression(argParser.getArgValues(), argParser.getComputeChecksumFlag(), argParser.getVerifyChecksumFlag());
    scriptExpression.parse();

    std::string output = buffer.str(); // capture the output
    std::cout.rdbuf(sbuf); // reset to standard output again
    // Check the output
    EXPECT_EQ(output, "raw(deadbeef)#89f8spxm\n");
}

TEST(ScriptExpressionTest, ComputeChecksum9) {
    const char *argv[] = {"bip380", "script-expression", "--compute-checksum", "raw(deadbeef)#"};
    int argc = 4;
    ArgParser argParser;
    argParser.loadArguments(argc, const_cast<char **>(argv));
    argParser.parse();

    std::stringstream buffer;
    std::streambuf *sbuf = std::cout.rdbuf(); // save old buffer
    std::cout.rdbuf(buffer.rdbuf()); // redirect std::cout to buffer

    ScriptExpression scriptExpression(argParser.getArgValues(), argParser.getComputeChecksumFlag(), argParser.getVerifyChecksumFlag());
    scriptExpression.parse();

    std::string output = buffer.str(); // capture the output
    std::cout.rdbuf(sbuf); // reset to standard output again
    // Check the output
    EXPECT_EQ(output, "raw(deadbeef)#89f8spxm\n");
}

TEST(ScriptExpressionTest, ComputeChecksum10) {
    const char *argv[] = {"bip380", "script-expression", "--compute-checksum", "raw(deadbeef)"};
    int argc = 4;
    ArgParser argParser;
    argParser.loadArguments(argc, const_cast<char **>(argv));
    argParser.parse();

    std::stringstream buffer;
    std::streambuf *sbuf = std::cout.rdbuf(); // save old buffer
    std::cout.rdbuf(buffer.rdbuf()); // redirect std::cout to buffer

    ScriptExpression scriptExpression(argParser.getArgValues(), argParser.getComputeChecksumFlag(), argParser.getVerifyChecksumFlag());
    scriptExpression.parse();

    std::string output = buffer.str(); // capture the output
    std::cout.rdbuf(sbuf); // reset to standard output again
    // Check the output
    EXPECT_EQ(output, "raw(deadbeef)#89f8spxm\n");
}

/**
 * Tests for basic --verify-checksum
 */
TEST(ScriptExpressionTest, VerifyChecksumBasic) {
    const char *argv[] = {"bip380", "script-expression", "--verify-checksum", "raw(deadbeef)#89f8spxm"};
    int argc = 4;
    ArgParser argParser;
    argParser.loadArguments(argc, const_cast<char **>(argv));
    argParser.parse();

    std::stringstream buffer;
    std::streambuf *sbuf = std::cout.rdbuf(); // save old buffer
    std::cout.rdbuf(buffer.rdbuf()); // redirect std::cout to buffer

    ScriptExpression scriptExpression(argParser.getArgValues(), argParser.getComputeChecksumFlag(), argParser.getVerifyChecksumFlag());
    scriptExpression.parse();

    std::string output = buffer.str(); // capture the output
    std::cout.rdbuf(sbuf); // reset to standard output again
    // Check the output
    EXPECT_EQ(output, "OK\n");
}

/**
 * Tests for space padding input
 */
TEST(ScriptExpressionTest, VerifyChecksumSpacPadding) {
    const char *argv[] = {"bip380", "script-expression", "--verify-checksum", "raw( deadbeef )#985dv2zl"};
    int argc = 4;
    ArgParser argParser;
    argParser.loadArguments(argc, const_cast<char **>(argv));
    argParser.parse();

    std::stringstream buffer;
    std::streambuf *sbuf = std::cout.rdbuf(); // save old buffer
    std::cout.rdbuf(buffer.rdbuf()); // redirect std::cout to buffer

    ScriptExpression scriptExpression(argParser.getArgValues(), argParser.getComputeChecksumFlag(), argParser.getVerifyChecksumFlag());
    scriptExpression.parse();

    std::string output = buffer.str(); // capture the output
    std::cout.rdbuf(sbuf); // reset to standard output again
    // Check the output
    EXPECT_EQ(output, "OK\n");
}

/**
 * Tests for caps-locked input
 */
TEST(ScriptExpressionTest, VerifyChecksumCapslock) {
    const char *argv[] = {"bip380", "script-expression", "--verify-checksum", "raw(DEADBEEF)#49w2hhz7"};
    int argc = 4;
    ArgParser argParser;
    argParser.loadArguments(argc, const_cast<char **>(argv));
    argParser.parse();

    std::stringstream buffer;
    std::streambuf *sbuf = std::cout.rdbuf(); // save old buffer
    std::cout.rdbuf(buffer.rdbuf()); // redirect std::cout to buffer

    ScriptExpression scriptExpression(argParser.getArgValues(), argParser.getComputeChecksumFlag(), argParser.getVerifyChecksumFlag());
    scriptExpression.parse();

    std::string output = buffer.str(); // capture the output
    std::cout.rdbuf(sbuf); // reset to standard output again
    // Check the output
    EXPECT_EQ(output, "OK\n");
}

/**
 * Tests for caps-locked input with random space in middle
 */
TEST(ScriptExpressionTest, VerifyChecksumCapslockSpace) {
    const char *argv[] = {"bip380", "script-expression", "--verify-checksum", "raw(DEAD BEEF)#qqn7ll2h"};
    int argc = 4;
    ArgParser argParser;
    argParser.loadArguments(argc, const_cast<char **>(argv));
    argParser.parse();

    std::stringstream buffer;
    std::streambuf *sbuf = std::cout.rdbuf(); // save old buffer
    std::cout.rdbuf(buffer.rdbuf()); // redirect std::cout to buffer

    ScriptExpression scriptExpression(argParser.getArgValues(), argParser.getComputeChecksumFlag(), argParser.getVerifyChecksumFlag());
    scriptExpression.parse();

    std::string output = buffer.str(); // capture the output
    std::cout.rdbuf(sbuf); // reset to standard output again
    // Check the output
    EXPECT_EQ(output, "OK\n");
}

/**
 * Tests for caps-locked input with random spaces in middle
 */
TEST(ScriptExpressionTest, VerifyChecksumCapslockSpaces) {
    const char *argv[] = {"bip380", "script-expression", "--verify-checksum",  "raw(DEA D BEEF)#egs9fwsr"};
    int argc = 4;
    ArgParser argParser;
    argParser.loadArguments(argc, const_cast<char **>(argv));
    argParser.parse();

    std::stringstream buffer;
    std::streambuf *sbuf = std::cout.rdbuf(); // save old buffer
    std::cout.rdbuf(buffer.rdbuf()); // redirect std::cout to buffer

    ScriptExpression scriptExpression(argParser.getArgValues(), argParser.getComputeChecksumFlag(), argParser.getVerifyChecksumFlag());
    scriptExpression.parse();

    std::string output = buffer.str(); // capture the output
    std::cout.rdbuf(sbuf); // reset to standard output again
    // Check the output
    EXPECT_EQ(output, "OK\n");
}

/**
 * Tests pkh expression
 */
TEST(ScriptExpressionTest, PkhVireifyChecksum) {
    const char *argv[] = {"bip380", "script-expression", "--verify-checksum",  "pkh(xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8)#vm4xc4ed"};
    int argc = 4;
    ArgParser argParser;
    argParser.loadArguments(argc, const_cast<char **>(argv));
    argParser.parse();

    std::stringstream buffer;
    std::streambuf *sbuf = std::cout.rdbuf(); // save old buffer
    std::cout.rdbuf(buffer.rdbuf()); // redirect std::cout to buffer

    ScriptExpression scriptExpression(argParser.getArgValues(), argParser.getComputeChecksumFlag(), argParser.getVerifyChecksumFlag());
    scriptExpression.parse();

    std::string output = buffer.str(); // capture the output
    std::cout.rdbuf(sbuf); // reset to standard output again
    // Check the output
    EXPECT_EQ(output, "OK\n");
}

/**
 * Tests pkh expression
 */
TEST(ScriptExpressionTest, PkhComputeChecksum) {
    const char *argv[] = {"bip380", "script-expression", "--compute-checksum",  "pkh(xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8)"};
    int argc = 4;
    ArgParser argParser;
    argParser.loadArguments(argc, const_cast<char **>(argv));
    argParser.parse();

    std::stringstream buffer;
    std::streambuf *sbuf = std::cout.rdbuf(); // save old buffer
    std::cout.rdbuf(buffer.rdbuf()); // redirect std::cout to buffer

    ScriptExpression scriptExpression(argParser.getArgValues(), argParser.getComputeChecksumFlag(), argParser.getVerifyChecksumFlag());
    scriptExpression.parse();

    std::string output = buffer.str(); // capture the output
    std::cout.rdbuf(sbuf); // reset to standard output again
    // Check the output
    EXPECT_EQ(output, "pkh(xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8)#vm4xc4ed\n");
}

/**
 * Tests pkh expression spaces
 */
TEST(ScriptExpressionTest, PkhComputeChecksumSpaces) {
    const char *argv[] = {"bip380", "script-expression", "--compute-checksum",  "pkh(   xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8)"};
    int argc = 4;
    ArgParser argParser;
    argParser.loadArguments(argc, const_cast<char **>(argv));
    argParser.parse();

    std::stringstream buffer;
    std::streambuf *sbuf = std::cout.rdbuf(); // save old buffer
    std::cout.rdbuf(buffer.rdbuf()); // redirect std::cout to buffer

    ScriptExpression scriptExpression(argParser.getArgValues(), argParser.getComputeChecksumFlag(), argParser.getVerifyChecksumFlag());
    scriptExpression.parse();

    std::string output = buffer.str(); // capture the output
    std::cout.rdbuf(sbuf); // reset to standard output again
    // Check the output
    EXPECT_EQ(output, "pkh(   xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8)#ujpe9npc\n");
}

/**
 * Tests pkh expression spaces verify
 */
TEST(ScriptExpressionTest, PkhVerifyChecksumSpaces) {
    const char *argv[] = {"bip380", "script-expression", "--verify-checksum",  "pkh(   xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8)#ujpe9npc"};
    int argc = 4;
    ArgParser argParser;
    argParser.loadArguments(argc, const_cast<char **>(argv));
    argParser.parse();

    std::stringstream buffer;
    std::streambuf *sbuf = std::cout.rdbuf(); // save old buffer
    std::cout.rdbuf(buffer.rdbuf()); // redirect std::cout to buffer

    ScriptExpression scriptExpression(argParser.getArgValues(), argParser.getComputeChecksumFlag(), argParser.getVerifyChecksumFlag());
    scriptExpression.parse();

    std::string output = buffer.str(); // capture the output
    std::cout.rdbuf(sbuf); // reset to standard output again
    // Check the output
    EXPECT_EQ(output, "OK\n");
}

/**
 * Tests multi expression spaces
 */
TEST(ScriptExpressionTest, MultiComputeChecksumSpaces) {
    const char *argv[] = {"bip380", "script-expression", "--compute-checksum",  "multi(2, xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8, xpub661MyMwAqRbcFW31YEwpkMuc5THy2PSt5bDMsktWQcFF8syAmRUapSCGu8ED9W6oDMSgv6Zz8idoc4a6mr8BDzTJY47LJhkJ8UB7WEGuduB)"};
    int argc = 4;
    ArgParser argParser;
    argParser.loadArguments(argc, const_cast<char **>(argv));
    argParser.parse();

    std::stringstream buffer;
    std::streambuf *sbuf = std::cout.rdbuf(); // save old buffer
    std::cout.rdbuf(buffer.rdbuf()); // redirect std::cout to buffer

    ScriptExpression scriptExpression(argParser.getArgValues(), argParser.getComputeChecksumFlag(), argParser.getVerifyChecksumFlag());
    scriptExpression.parse();

    std::string output = buffer.str(); // capture the output
    std::cout.rdbuf(sbuf); // reset to standard output again
    // Check the output
    EXPECT_EQ(output, "multi(2, xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8, xpub661MyMwAqRbcFW31YEwpkMuc5THy2PSt5bDMsktWQcFF8syAmRUapSCGu8ED9W6oDMSgv6Zz8idoc4a6mr8BDzTJY47LJhkJ8UB7WEGuduB)#5jlj4shz\n");
}

/**
 * Tests multi expression spaces verify
 */
TEST(ScriptExpressionTest, MultiVerifyChecksumSpaces) {
    const char *argv[] = {"bip380", "script-expression", "--verify-checksum",  "multi(2, xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8, xpub661MyMwAqRbcFW31YEwpkMuc5THy2PSt5bDMsktWQcFF8syAmRUapSCGu8ED9W6oDMSgv6Zz8idoc4a6mr8BDzTJY47LJhkJ8UB7WEGuduB)#5jlj4shz"};
    int argc = 4;
    ArgParser argParser;
    argParser.loadArguments(argc, const_cast<char **>(argv));
    argParser.parse();

    std::stringstream buffer;
    std::streambuf *sbuf = std::cout.rdbuf(); // save old buffer
    std::cout.rdbuf(buffer.rdbuf()); // redirect std::cout to buffer

    ScriptExpression scriptExpression(argParser.getArgValues(), argParser.getComputeChecksumFlag(), argParser.getVerifyChecksumFlag());
    scriptExpression.parse();

    std::string output = buffer.str(); // capture the output
    std::cout.rdbuf(sbuf); // reset to standard output again
    // Check the output
    EXPECT_EQ(output, "OK\n");
}


/**
 * Tests really long checksum
 */
TEST(ScriptExpressionTest, ReallyLongChecksum) {
    const char *argv[] = {"bip380", "script-expression", "--compute-checksum",  "raw(deadbeef)#sh(multi(0, xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8))"};
    int argc = 4;
    ArgParser argParser;
    argParser.loadArguments(argc, const_cast<char **>(argv));
    argParser.parse();

    std::stringstream buffer;
    std::streambuf *sbuf = std::cout.rdbuf(); // save old buffer
    std::cout.rdbuf(buffer.rdbuf()); // redirect std::cout to buffer

    ScriptExpression scriptExpression(argParser.getArgValues(), argParser.getComputeChecksumFlag(), argParser.getVerifyChecksumFlag());
    scriptExpression.parse();

    std::string output = buffer.str(); // capture the output
    std::cout.rdbuf(sbuf); // reset to standard output again
    // Check the output
    EXPECT_EQ(output, "raw(deadbeef)#89f8spxm\n");
}


/**
 * Tests really long checksum with multiple hashes
 */
TEST(ScriptExpressionTest, ReallyLongChecksumAndMultipleHashes) {
    const char *argv[] = {"bip380", "script-expression", "--compute-checksum",  "raw(deadbeef)##sh(multi(0, xpub661MyMwAqRbc#gS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8#)#)#"};
    int argc = 4;
    ArgParser argParser;
    argParser.loadArguments(argc, const_cast<char **>(argv));
    argParser.parse();

    std::stringstream buffer;
    std::streambuf *sbuf = std::cout.rdbuf(); // save old buffer
    std::cout.rdbuf(buffer.rdbuf()); // redirect std::cout to buffer

    ScriptExpression scriptExpression(argParser.getArgValues(), argParser.getComputeChecksumFlag(), argParser.getVerifyChecksumFlag());
    scriptExpression.parse();

    std::string output = buffer.str(); // capture the output
    std::cout.rdbuf(sbuf); // reset to standard output again
    // Check the output
    EXPECT_EQ(output, "raw(deadbeef)#89f8spxm\n");
}


/**
 * Tests duplicate expressions
 */
TEST(ScriptExpressionTest, duplicatedExpressionRaw) {
    const char *argv[] = {"bip380", "script-expression", "--compute-checksum",  "raw(deadbeef)raw(deadbeef)"};
    int argc = 4;
    EXPECT_THROW({
    	ArgParser argParser;
    	argParser.loadArguments(argc, const_cast<char **>(argv));
    	argParser.parse();

    	ScriptExpression scriptExpression(argParser.getArgValues(), argParser.getComputeChecksumFlag(), argParser.getVerifyChecksumFlag());
	    scriptExpression.parse();
    }, std::invalid_argument);
}

/**
 * Tests duplicate expressions
 */
TEST(ScriptExpressionTest, duplicatedExpression) {
    const char *argv[] = {"bip380", "script-expression", "--compute-checksum",  "raw(deadbeef)sh(multi(0, xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8))"};
    int argc = 4;
    EXPECT_THROW({
    	ArgParser argParser;
    	argParser.loadArguments(argc, const_cast<char **>(argv));
    	argParser.parse();

    	ScriptExpression scriptExpression(argParser.getArgValues(), argParser.getComputeChecksumFlag(), argParser.getVerifyChecksumFlag());
	    scriptExpression.parse();
    }, std::invalid_argument);
}