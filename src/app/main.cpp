#include <iostream>

#include "ArgParser/ArgParser.h"
#include "ScriptExpression/ScriptExpression.h"
#include "KeyExpression/KeyExpression.h"
#include "DeriveKey/DeriveKey.h"

extern "C"
{
#include <btc/ecc.h>
}

/**
 * Prints the explanatory string of an exception. If the exception is nested, recurses to print the explanatory string of the exception it holds.
 * This function taken verbatim from https://en.cppreference.com/w/cpp/error/throw_with_nested reference
 * @param ex exception with nested exceptions
 * @param level level to show
 */
void print_exception(const std::exception &ex, int level = 0)
{
    std::cerr << std::string(level, ' ') << "exception: " << ex.what() << std::endl;
    try
    {
        rethrow_if_nested(ex);
    }
    catch (const std::exception &nestedException)
    {
        print_exception(nestedException, level + 1);
    }
    catch (...)
    {
    }
}

int main(int argc, char *argv[])
{
    btc_ecc_start();

    ArgParser argParser;

    try
    {
        argParser.loadArguments(argc, argv);
        argParser.parse();
    }
    catch (const std::exception &ex)
    {
        print_exception(ex);
        return 1;
    }

    if (argParser.argExists("derive-key"))
    {
        deriveKey(argParser.getArgValues(), argParser.getFilepath());
    }
    else if (argParser.argExists("key-expression"))
    {
        runKeyExpression(argParser.getArgValues());
    }
    else if (argParser.argExists("script-expression"))
    {
        ScriptExpression scriptExpression(argParser.getArgValues(), argParser.getComputeChecksumFlag(), argParser.getVerifyChecksumFlag());
        scriptExpression.parse();
    }
    btc_ecc_stop();
    return 0;
}
