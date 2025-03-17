//
// Created by Pospes on 15.03.2025.
//

#pragma once

#include <vector>

using namespace std;

class ArgParser {
private:
    vector<string> argList;  // Vector of input arguments

    vector<string> argValuesVector;  // Vector of parsed output argument values (or expressions)
    string argFilepath;  // Contains the filepath from argument, if provided

    void printHelp();
    bool argExists(const string &arg);
    string getArgValue(const string &originalArg);
    bool multipleArgsExist(const string &arg);
    bool invalidKeyArgsAmount();
    bool invalidKeyArgsPosition();
    vector<string> readArgValuesFromCLI();

    bool parseFilepath(const string &filepath);

    //todo getter setter, script expr args

    void getDeriveKeyArgs(vector<string> *tmpArgValueVector, string *filepath);
    void getKeyExpressionArgs(vector<string> *tmpArgValueVector);
    void getScriptExpressionArgs(vector<string> *tmpArgValueVector, bool *verifyChecksumFlag, bool *computeChecksumFlag);

    void parseDeriveKey();
    void parseKeyExpression();
    void parseScriptExpression();

    void parse();

public:
    ArgParser(int argc, char *argv[]);
};


