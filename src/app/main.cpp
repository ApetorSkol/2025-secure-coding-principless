#include <iostream>

#include "ArgParser/ArgParser.h"
#include "ScriptExpression/ScriptExpression.h"

int main(int argc, char *argv[]) {

    ArgParser argParser(argc, argv);

    try {
        argParser.parse();
    }
    catch (const invalid_argument &ex) {
        cerr << "[ERROR]: main: invalid_argument exception occured: " << ex.what() << endl;
        return 1;
    }
    catch (const exception &ex) {
        cerr << "[ERROR]: main: general exception occured" << endl;
        return 1;
    }


    if (argParser.argExists("derive-key")) {
        // doDeriveKeyThings(argParser.getArgValues(), argParser.returnFilepath());
    }
    else if (argParser.argExists("key-expression")) {
        // doKeyExpressionThings(argParser.getArgValues(), argParser.returnFilepath());
    }
    else if (argParser.argExists("script-expression")) {
        ScriptExpression scriptExpression(argParser.getArgValues(), argParser.getVerifyChecksumFlag(), argParser.getComputeChecksumFlag());
        scriptExpression.parse();
    }


    return 0;
}

