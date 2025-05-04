/**
 * Project: PV286 2024/2025 Project
 * @file ArgParserTest.cpp
 * @author Jan Kuča
 * @brief GTest unit tests for the ArgParser component
 * @date 2025-03-20
 *
 * This file contains GTest-based unit tests for the ArgParser class. 
 * It checks correct detection of CLI arguments, subcommand usage, 
 * error handling, and special flags such as --verify-checksum or --compute-checksum.
 *
 * © 2025
 */

#include <gtest/gtest.h>
#include "../app/ArgParser/ArgParser.h"
#include <stdexcept>
#include <vector>
#include <string>

/**
 * Tests whether the arguments are correctly detected.
 */
TEST(ArgParserTest, DetectArguments) {
    const char *argv[] = {"bip380", "derive-key", "00aabbcc"};
    int argc = 3;
    ArgParser parser;
    parser.loadArguments(argc, const_cast<char **>(argv));

    EXPECT_TRUE(parser.argExists("derive-key"));
    EXPECT_FALSE(parser.argExists("key-expression"));
}

/**
 * Tests proper handling of multiple arguments.
 */
TEST(ArgParserTest, MultipleArguments) {
    const char *argv[] = {"bip380", "script-expression", "--verify-checksum"};
    int argc = 3;
    ArgParser parser;
    parser.loadArguments(argc, const_cast<char **>(argv));

    EXPECT_TRUE(parser.argExists("script-expression"));
    EXPECT_TRUE(parser.argExists("--verify-checksum"));
}

/**
 * Tests correct detection of `--help`.
 */
TEST(ArgParserTest, HelpCommand) {
    const char *argv[] = {"bip380", "--help"};
    int argc = 2;
    ArgParser parser;
    parser.loadArguments(argc, const_cast<char **>(argv));

    EXPECT_TRUE(parser.argExists("--help"));
}

/**
 * Tests that parse() throws std::invalid_argument 
 * when there is only 1 argument (the program name) 
 * instead of the required 2 or more.
 */
TEST(ArgParserTest, InvalidArguments) {
    const char *argv[] = {"bip380"};
    int argc = 1;

    EXPECT_THROW({
                     ArgParser parser;
                     parser.loadArguments(argc, const_cast<char **>(argv));
                     parser.parse();  // should trigger invalid_argument
                 }, std::invalid_argument);
}

/**
 * Helper function to create a char** array from a vector of strings.
 */
static std::vector<char*> makeArgv(const std::vector<std::string>& args) {
    std::vector<char*> argv;
    argv.reserve(args.size());
    for (auto& s : args) {
        argv.push_back(const_cast<char*>(s.c_str()));
    }
    return argv;
}

/**
 * Tests that providing too few arguments results in an exception.
 * According to the specification: if the sub-command is missing 
 * (and there is no --help), it is an error.
 */
TEST(ArgParserTest, ThrowsIfTooFewArguments) {
    // Program name only
    {
        std::vector<std::string> args = {"bip380"};
        auto argv = makeArgv(args);
        EXPECT_THROW({
                         ArgParser parser;
                         parser.loadArguments(static_cast<int>(argv.size()), argv.data());

                         parser.parse();
                     }, std::invalid_argument);
    }

    // Program name plus just one more argument (which is not --help)
    {
        std::vector<std::string> args = {"bip380", "someArg"};
        auto argv = makeArgv(args);
        EXPECT_THROW({
                         ArgParser parser;
                         parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                         parser.parse();
                     }, std::invalid_argument);
    }
}


/**
 * Tests that repeated subcommands cause an exception
 * (i.e., when the user provides more than one of: derive-key, key-expression, script-expression).
 */
TEST(ArgParserTest, InvalidKeyArgsAmountThrows) {
    // "derive-key" repeated
    {
        std::vector<std::string> args = {"bip380", "derive-key", "derive-key"};
        auto argv = makeArgv(args);
        EXPECT_THROW({
                         ArgParser parser;
                         parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                         parser.parse();
                     }, std::invalid_argument);
    }

    // "key-expression" repeated
    {
        std::vector<std::string> args = {"bip380", "key-expression", "key-expression"};
        auto argv = makeArgv(args);
        EXPECT_THROW({
                         ArgParser parser;
                         parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                         parser.parse();
                     }, std::invalid_argument);
    }

    // Multiple sub-commands are present
    {
        std::vector<std::string> args = {"bip380", "derive-key", "script-expression"};
        auto argv = makeArgv(args);
        EXPECT_THROW({
                         ArgParser parser;
                         parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                         parser.parse();
                     }, std::invalid_argument);
    }
}

/**
 * Tests that if the first argument is NOT one of the valid subcommands
 * (derive-key, key-expression, script-expression) and not --help,
 * we get an exception.
 */
TEST(ArgParserTest, InvalidKeyArgsPositionThrows) {
    std::vector<std::string> args = {
            "bip380", "random-arg", "some-other-arg"
    };
    auto argv = makeArgv(args);
    EXPECT_THROW({
                     ArgParser parser;
                     parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                     parser.parse();
                 }, std::invalid_argument);
}

/**
 * Valid scenario #1: "derive-key" used as the first arg.
 */
TEST(ArgParserTest, DeriveKeyValidScenario) {
    // e.g. bip380 derive-key 00aabbcc00aabbcc00aabbcc00aabbcc
    std::vector<std::string> args = {"bip380", "derive-key", "00aabbcc00aabbcc00aabbcc00aabbcc"};
    auto argv = makeArgv(args);

    EXPECT_NO_THROW({
                        ArgParser parser;
                        parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                        parser.parse();

                        auto retrievedArgs = parser.getArgValues();
                        ASSERT_EQ(retrievedArgs.size(), 1u);
                        EXPECT_EQ(retrievedArgs[0], "00aabbcc00aabbcc00aabbcc00aabbcc");
                    });
}

/**
 * Valid scenario #2: "key-expression" used as the first arg.
 */
TEST(ArgParserTest, KeyExpressionValidScenario) {
    // e.g. bip380 key-expression 0260b2003c386519fc9eadf2b5cf124dd8eea4c4e68d5e154050a9346ea98ce600
    std::vector<std::string> args = {"bip380", "key-expression", "0260b2003c386519fc9eadf2b5cf124dd8eea4c4e68d5e154050a9346ea98ce600"};
    auto argv = makeArgv(args);

    EXPECT_NO_THROW({
                        ArgParser parser;
                        parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                        parser.parse();
                        auto retrievedArgs = parser.getArgValues();
                        ASSERT_EQ(retrievedArgs.size(), 1u);
                        EXPECT_EQ(retrievedArgs[0], "0260b2003c386519fc9eadf2b5cf124dd8eea4c4e68d5e154050a9346ea98ce600");
                    });
}

/**
 * Valid scenario #3: "script-expression"
 */
TEST(ArgParserTest, ScriptExpressionValidScenario) {
    // e.g. bip380 script-expression "pk(0260b2003c386519fc9eadf2b5cf124dd8eea4c4e68d5e154050a9346ea98ce600)"
    std::vector<std::string> args = {"bip380", "script-expression", "pk(0260b2003c386519fc9eadf2b5cf124dd8eea4c4e68d5e154050a9346ea98ce600)"};
    auto argv = makeArgv(args);

    EXPECT_NO_THROW({
                        ArgParser parser;
                        parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                        parser.parse();
                        auto retrievedArgs = parser.getArgValues();
                        ASSERT_EQ(retrievedArgs.size(), 1u);
                        EXPECT_EQ(retrievedArgs[0], "pk(0260b2003c386519fc9eadf2b5cf124dd8eea4c4e68d5e154050a9346ea98ce600)");
                    });
}

/**
 * Testing the --verify-checksum or --compute-checksum flags
 * (which are only valid with script-expression).
 */
TEST(ArgParserTest, ScriptExpressionWithVerifyChecksum) {
    std::vector<std::string> args = {"bip380", "script-expression", "--verify-checksum"};
    auto argv = makeArgv(args);

    EXPECT_THROW({
                     ArgParser parser;
                     parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                     parser.parse();
                 }, std::invalid_argument);
    /*
    EXPECT_NO_THROW({
        ArgParser parser;
    parser.loadArguments(static_cast<int>(argv.size()), argv.data());
        parser.parse();
        EXPECT_TRUE(parser.getVerifyChecksumFlag());
        EXPECT_FALSE(parser.getComputeChecksumFlag());
    });
     */
}

TEST(ArgParserTest, ScriptExpressionWithComputeChecksum) {
    std::vector<std::string> args = {"bip380", "script-expression", "--compute-checksum"};
    auto argv = makeArgv(args);

    EXPECT_THROW({
                     ArgParser parser;
                     parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                     parser.parse();
                 }, std::invalid_argument);
    /*
    EXPECT_NO_THROW({
        ArgParser parser;
    parser.loadArguments(static_cast<int>(argv.size()), argv.data());
        parser.parse();
        EXPECT_FALSE(parser.getVerifyChecksumFlag());
        EXPECT_TRUE(parser.getComputeChecksumFlag());
    });
     */
}

/**
 * Using both verify-checksum & compute-checksum should throw.
 */
TEST(ArgParserTest, ScriptExpressionWithBothChecksumFlagsThrows) {
    std::vector<std::string> args = {
            "bip380",
            "script-expression",
            "--verify-checksum",
            "--compute-checksum"
    };
    auto argv = makeArgv(args);

    EXPECT_THROW({
                     ArgParser parser;
                     parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                     parser.parse();
                 }, std::invalid_argument);
}

/**
 * Test the optional --path usage in "derive-key".
 */
TEST(ArgParserTest, DeriveKeyWithPath) {
    // e.g. bip380 derive-key --path /0H/1 ff00ff00ff00ff00ff00ff00ff00ff00
    std::vector<std::string> args = {
            "bip380",
            "derive-key",
            "--path",
            "/0H/1",
            "ff00ff00ff00ff00ff00ff00ff00ff00"
    };
    auto argv = makeArgv(args);

    EXPECT_NO_THROW({
                        ArgParser parser;
                        parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                        parser.parse();

                        // For example: EXPECT_EQ(parser.getFilepath(), "/0H/1");
                        // Depending on ArgParser implementation.
                    });
}

/**
 * Example test verifying that argExists() behaves as expected.
 * Checks directly argExists(), not parse().
 */
TEST(ArgParserTest, ArgExistsDirectCheck) {
    std::vector<std::string> args = {"bip380", "derive-key", "--custom-flag"};
    auto argv = makeArgv(args);

    ArgParser parser;
    parser.loadArguments(static_cast<int>(argv.size()), argv.data());
    EXPECT_TRUE(parser.argExists("derive-key"));
    EXPECT_TRUE(parser.argExists("--custom-flag"));
    EXPECT_FALSE(parser.argExists("no-such-flag"));
}

/**
 * Test that extremely long single argument is rejected
 * (if your application wants to limit argument length).
 * For example, seed arguments or path arguments shouldn't exceed 
 * a certain length. If your specification allows large inputs, 
 * you might handle them differently, but here's an example.
 */
TEST(ArgParserTest, RejectsExtremelyLongArgument) {
    // Construct a huge string (e.g., 10,000 'a' characters)
    std::string longArg(10000, 'a');

    std::vector<std::string> args = {"bip380", "derive-key", longArg};
    auto argv = makeArgv(args);

    // If your ArgParser should reject extremely large arguments,
    // we expect an invalid_argument here:
    EXPECT_THROW({
                     ArgParser parser;
                     parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                     parser.parse();
                 }, std::invalid_argument);
}

/**
 * Test for invalid characters in a supposed hex seed.
 * For instance, "gg" is not valid hex; the parser or 
 * deeper validation should reject it.
 *
 * If your code doesn't currently enforce hex-checking,
 * you'd need to implement it. 
 */
TEST(ArgParserTest, InvalidHexSeedCharacters) {
    // "zz" is clearly invalid for hex
    std::vector<std::string> args = {"bip380", "derive-key", "00aazz11"};
    auto argv = makeArgv(args);

    EXPECT_THROW({
                     ArgParser parser;
                     parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                     parser.parse();
                     // presumably in parseDeriveKey() you'd detect invalid hex
                     // and throw invalid_argument
                 }, std::invalid_argument);
}

/**
 * Test that special characters in the path argument 
 * (like newlines or some escape sequences) lead to rejection.
 * If your spec allows certain characters only (/0H/1, etc.), 
 * you should ensure the parser doesn't accept invalid ones.
 */
TEST(ArgParserTest, InvalidCharactersInPath) {
    // In normal BIP32 path format, we expect e.g. "/0H/1". 
    // Let's introduce invalid chars like "???" or control chars.
    std::vector<std::string> args = {
            "bip380",
            "derive-key",
            "--path",
            "/0H/1???",  // invalid
            "00aabbcc"
    };
    auto argv = makeArgv(args);

    EXPECT_THROW({
                     ArgParser parser;
                     parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                     parser.parse();
                     // parseDeriveKey() should detect this path is invalid
                 }, std::invalid_argument);
}

/**
 * Test that suspicious substrings or injection attempts 
 * in 'script-expression' are rejected.
 * This example checks if parser properly filters out 
 * unexpected colons, semicolons, or code injection attempts. 
 *
 * In reality, a purely local ArgParser might not be as 
 * vulnerable to injection, but we want to ensure 
 * it doesn't incorrectly interpret input.
 */
TEST(ArgParserTest, ScriptExpressionPotentialInjectionRejected) {
    // Suppose the user tries to pass something that might be 
    // suspicious, e.g. "pk(02ab; rm -rf / )" 
    // If your parser explicitly disallows certain sequences, 
    // you can detect it and throw.
    std::vector<std::string> args = {
            "bip380",
            "script-expression",
            "pk(02ab; rm -rf /)"
    };
    auto argv = makeArgv(args);

    EXPECT_THROW({
                     ArgParser parser;
                     parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                     parser.parse();
                     // parseScriptExpression() or subsequent validation
                     // could detect forbidden chars or syntax.
                 }, std::invalid_argument);
}

/**
 * Test that an argument resembling a subcommand prefix
 * but with trailing garbage is rejected.
 * E.g. user typed "derive-keyXYZ" by accident. 
 */
TEST(ArgParserTest, RejectsInvalidSubcommandPrefix) {
    std::vector<std::string> args = {"bip380", "derive-keyXYZ", "00aabbcc"};
    auto argv = makeArgv(args);

    // The subcommand "derive-keyXYZ" is not recognized, 
    // so parse() should fail.
    EXPECT_THROW({
                     ArgParser parser;
                     parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                     parser.parse();
                 }, std::invalid_argument);
}

/**
 * Test that unknown flags (e.g. something that is not 
 * --verify-checksum or --compute-checksum or --path) 
 * are rejected. 
 *
 * If your ArgParser is strict about unknown flags, 
 * it should throw. If it's allowed to ignore unknown flags, 
 * you'd adapt the test accordingly.
 */
TEST(ArgParserTest, RejectUnknownFlags) {
    std::vector<std::string> args = {
            "bip380",
            "script-expression",
            "--random-flag",
            "pk(02abcdef)"
    };
    auto argv = makeArgv(args);

    EXPECT_THROW({
                     ArgParser parser;
                     parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                     parser.parse();
                 }, std::invalid_argument);
}

/**
 * Test what happens if user tries to use multiple --path arguments.
 * The specification might allow only one --path. 
 * If so, the second one should trigger an error.
 */
TEST(ArgParserTest, MultiplePathsShouldThrow) {
    std::vector<std::string> args = {
            "bip380",
            "derive-key",
            "--path",
            "/0/1H",
            "--path",
            "/2/3H",
            "ff00ff00"
    };
    auto argv = makeArgv(args);

    EXPECT_THROW({
                     ArgParser parser;
                     parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                     parser.parse();
                 }, std::invalid_argument);
}

/**
 * Example of extremely long path input that might 
 * lead to a buffer or integer overflow if not handled carefully.
 * 
 * e.g. "/0H/1/2H" repeated many times. 
 */
TEST(ArgParserTest, ExtremelyLongPath) {
    // Construct a path containing repeated segments
    std::string repeatedSegment = "/0H/1/2H/3/2147483647H";
    std::string largePath;
    for (int i = 0; i < 200; i++) {
        largePath += repeatedSegment;
    }

    std::vector<std::string> args = {
            "bip380",
            "derive-key",
            "--path",
            largePath,
            "01abcdef"
    };
    auto argv = makeArgv(args);

    EXPECT_THROW({
                     ArgParser parser;
                     parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                     parser.parse();
                 }, std::invalid_argument);
}

/**
 * Tests for --verify-checksum with short checksum
 */
TEST(ScriptExpressionTest, VerifyChecksumShortChecksum) {
    const char *argv[] = {"bip380", "script-expression", "--verify-checksum",  "raw(DEA D BEEF)#egs9"};
    int argc = 4;
    EXPECT_THROW({
                     ArgParser parser;
                     parser.loadArguments(argc, const_cast<char **>(argv));
                     parser.parse();
                 }, std::invalid_argument);
}


/**
 * Tests for --verify-checksum with no checksum
 */
TEST(ScriptExpressionTest, VerifyChecksumNoChecksum) {
    const char *argv[] = {"bip380", "script-expression", "--verify-checksum",  "raw(DEADBEEF)#"};
    int argc = 4;
    EXPECT_THROW({
                     ArgParser parser;
                     parser.loadArguments(argc, const_cast<char **>(argv));
                     parser.parse();
                 }, std::invalid_argument);
}

/**
 * Tests for --verify-checksum with no hashtag
 */
TEST(ScriptExpressionTest, VerifyChecksumNoHashtag) {
    const char *argv[] = {"bip380", "script-expression", "--verify-checksum",  "raw(DEADBEEF)"};
    int argc = 4;

    EXPECT_THROW({
                     ArgParser parser;
                     parser.loadArguments(argc, const_cast<char **>(argv));
                     parser.parse();
                 }, std::invalid_argument);
}

/**
 * Tests for invalid operator raw
 */
TEST(ScriptExpressionTest, InvalidOperatorRaw) {
    const char *argv[] = {"bip380", "script-expression", "--verify-checksum",  "ra w(DEADBEEF)"};
    int argc = 4;

    EXPECT_THROW({
                     ArgParser parser;
                     parser.loadArguments(argc, const_cast<char **>(argv));
                     parser.parse();
                 }, std::invalid_argument);
}

/**
 * Tests for invalid operator pk
 */
TEST(ScriptExpressionTest, InvalidOperatorPk) {
    const char *argv[] = {"bip380", "script-expression", "--verify-checksum",  "p k(0260b2003c386519fc9eadf2b5cf124dd8eea4c4e68d5e154050a9346ea98ce600)"};
    int argc = 4;

    EXPECT_THROW({
                     ArgParser parser;
                     parser.loadArguments(argc, const_cast<char **>(argv));
                     parser.parse();
                 }, std::invalid_argument);
}



TEST(ArgParserTest, validSpace) {
    std::vector<std::string> args = {
            "bip380",
            "script-expression",
            "sh(multi(1, 5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ))",
    };
    auto argv = makeArgv(args);

    EXPECT_NO_THROW({
                        ArgParser parser;
                        parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                        parser.parse();
                    });
}


TEST(ArgParserTest, tabSpace) {
    std::vector<std::string> args = {
            "bip380",
            "script-expression",
            "\t sh(multi(1, 5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ))\t",
    };
    auto argv = makeArgv(args);

    EXPECT_THROW({
                        ArgParser parser;
                        parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                        parser.parse();
                    }, std::invalid_argument);
}


TEST(ArgParserTest, tabSpace1) {
    std::vector<std::string> args = {
            "bip380",
            "script-expression",
            "\t sh(multi(1, 5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ)\t)\t",
    };
    auto argv = makeArgv(args);

    EXPECT_THROW({
                        ArgParser parser;
                        parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                        parser.parse();
                    }, std::invalid_argument);
}


TEST(ArgParserTest, tabSpace2) {
    std::vector<std::string> args = {
            "bip380",
            "script-expression",
            "\t sh(multi(1, 5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ\n)\t)\t",
    };
    auto argv = makeArgv(args);

    EXPECT_THROW({
                        ArgParser parser;
                        parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                        parser.parse();
                    }, std::invalid_argument);
}


TEST(ArgParserTest, newLinaAtStrangePlaces) {
    std::vector<std::string> args = {
            "bip380",
            "script-expression",
            "\n sh(multi(1, 5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ))",
    };
    auto argv = makeArgv(args);

    EXPECT_THROW({
                        ArgParser parser;
                        parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                        parser.parse();
                    }, std::invalid_argument);
}


TEST(ArgParserTest, newLinaAtStrangePlaces1) {
    std::vector<std::string> args = {
            "bip380",
            "script-expression",
            " \n sh(multi(1, 5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ))",
    };
    auto argv = makeArgv(args);

    EXPECT_THROW({
                        ArgParser parser;
                        parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                        parser.parse();
                    }, std::invalid_argument);
}


TEST(ArgParserTest, newLinaAtStrangePlaces3) {
    std::vector<std::string> args = {
            "bip380",
            "script-expression",
            "dadsad \n sh(multi(1, 5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ))",
    };
    auto argv = makeArgv(args);

    EXPECT_THROW({
                        ArgParser parser;
                        parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                        parser.parse();
                    }, std::invalid_argument);
}


TEST(ArgParserTest, newLinaAtStrangePlaces4) {
    std::vector<std::string> args = {
            "bip380",
            "script-expression",
            " sh(multi(1, 5HueCGU8rMjxEXx\niPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ))",
    };
    auto argv = makeArgv(args);

    EXPECT_THROW({
                        ArgParser parser;
                        parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                        parser.parse();
                    }, std::invalid_argument);
}


TEST(ArgParserTest, newLinaAtStrangePlaces5) {
    std::vector<std::string> args = {
            "bip380",
            "script-expression",
            " sh(multi(1, 5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ))\n",
    };
    auto argv = makeArgv(args);

    EXPECT_THROW({
                        ArgParser parser;
                        parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                        parser.parse();
                    }, std::invalid_argument);
}


TEST(ArgParserTest, newLinaAtStrangePlaces6) {
    std::vector<std::string> args = {
            "bip380",
            "script-expression",
            "sh(multi(1, 5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ)\n)",
    };
    auto argv = makeArgv(args);

    EXPECT_THROW({
                        ArgParser parser;
                        parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                        parser.parse();
                    }, std::invalid_argument);
}


TEST(ArgParserTest, newLinaAtStrangePlaces7) {
    std::vector<std::string> args = {
            "bip380",
            "script-expression",
            " sh(multi(1, 5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ\n))",
    };
    auto argv = makeArgv(args);

    EXPECT_THROW({
                        ArgParser parser;
                        parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                        parser.parse();
                    }, std::invalid_argument);
}


TEST(ArgParserTest, validKeyOrigin1) {
    std::vector<std::string> args = {
            "bip380",
            "script-expression",
            "sh(multi(1, [deadbeef/0h/1h/2]5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ))",
    };
    auto argv = makeArgv(args);

    EXPECT_NO_THROW({
                        ArgParser parser;
                        parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                        parser.parse();
                    });
}

TEST(ArgParserTest, stoiOverflow) {
    std::string repeated = "9";
    std::string finalStr;
    for (int x = 0; x < 900; x++)
        finalStr += repeated;

    std::vector<std::string> args = {
            "bip380",
            "script-expression",
            "sh(multi(" + finalStr + ",5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ))",
    };
    auto argv = makeArgv(args);


    for (int x = 0; x < 5; x++) {
        EXPECT_THROW({
                         ArgParser parser;
                         parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                         parser.parse();
                     }, std::invalid_argument);
    }
}


TEST(ArgParserTest, multipleArgValuesDifferentType) {
    std::vector<std::string> args = {
            "bip380",
            "script-expression",
            "sh(multi(1, [deadbeef/0h/1h/2]5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ, [deadbeef/0h/1h/2]0260b2003c386519fc9eadf2b5cf124dd8eea4c4e68d5e154050a9346ea98ce600))",
    };
    auto argv = makeArgv(args);

    EXPECT_NO_THROW({
                        ArgParser parser;
                        parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                        parser.parse();
                    });
}

TEST(ArgParserTest, unicode) {
    std::vector<std::string> args = {
            "bip380",
            "script-expression",
            "sh(multi(1, 0260b2003c386519fc9eadf2b5čf124dd8eea4c4e68d5e154050a9346ea98ce600))))",
    };
    auto argv = makeArgv(args);

    EXPECT_THROW({
                     ArgParser parser;
                     parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                     parser.parse();
                 }, std::invalid_argument);
}

TEST(ArgParserTest, foreignChars) {
    std::vector<std::string> args = {
            "bip380",
            "script-expression",
            "@#!",
            "sh(multi(1, 0260b2003c386519fc9eadf2b5cf124dd8eea4c4e68d5e154050a9346ea98ce600))))",
    };
    auto argv = makeArgv(args);

    EXPECT_THROW({
                     ArgParser parser;
                     parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                     parser.parse();
                 }, std::invalid_argument);
}


TEST(ArgParserTest, invalidWIF) {
    std::vector<std::string> args = {
            "bip380",
            "script-expression",
            "sh(multi(1, 5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTj",
    };
    auto argv = makeArgv(args);

    EXPECT_THROW({
                        ArgParser parser;
                        parser.loadArguments(static_cast<int>(argv.size()), argv.data());
                        parser.parse();
                    }, std::invalid_argument);
}


/*
TEST(ArgParserTest, dangerousArgc) {
    const char *argv[] = {"bip380", "script-expression", "--verify-checksum"};
    int argc = 50;

    EXPECT_THROW({
                     ArgParser parser;
                     parser.loadArguments(argc, const_cast<char **>(argv));
                 }, std::invalid_argument);
}
 */