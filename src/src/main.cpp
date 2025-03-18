#include <iostream>

#include "ArgParser/ArgParser.h"


int main(int argc, char *argv[]) {

    ArgParser ArgParser(argc, argv);

    try {
        ArgParser.parse();
    }
    catch (const invalid_argument &ex) {
        cerr << "[ERROR]: main: invalid_argument exception occured: " << ex.what() << endl;
        return 1;
    }
    catch (const exception &ex) {
        cerr << "[ERROR]: main: general exception occured" << endl;
        return 1;
    }


    if (ArgParser.argExists("derive-key")) {
        // doDeriveKeyThings(ArgParser.getArgValues(), ArgParser.returnFilepath());
    }
    else if (ArgParser.argExists("key-expression")) {
        // doKeyExpressionThings(ArgParser.getArgValues(), ArgParser.returnFilepath());
    }
    else if (ArgParser.argExists("script-expression")) {
        // doScriptExpressionThings(ArgParser.getArgValues());
    }



    return 0;
}

