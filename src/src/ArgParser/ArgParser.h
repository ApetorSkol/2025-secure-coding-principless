/**
 * Project: PV286 2024/2025 Project
 * @file ArgParser.h
 * @author Pospíšil Zbyněk (xpospis)
 * @brief Implementation of CLI argument parser
 * @date 2025-03-15
 *
 * @copyright Copyright (c) 2025
 *
 */


#pragma once

#include <vector>

using namespace std;

class ArgParser {
private:
    vector<string> argList;  // Vector of input arguments

    vector<string> argValuesVector;  // Vector of parsed output argument values (or expressions)
    string argFilepath;  // Contains the filepath from argument, if provided

    void printHelp();
    bool multipleArgsExist(const string &arg);
    bool invalidKeyArgsAmount();
    bool invalidKeyArgsPosition();
    vector<string> readArgValuesFromCLI();

    bool parseFilepath(const string &filepath);

    //todo script expr args

    void getDeriveKeyArgs(vector<string> *tmpArgValueVector, string *filepath);
    void getKeyExpressionArgs(vector<string> *tmpArgValueVector);
    void getScriptExpressionArgs(vector<string> *tmpArgValueVector, bool *verifyChecksumFlag, bool *computeChecksumFlag);

    void parseDeriveKey();
    void parseKeyExpression();
    void parseScriptExpression();

public:
    ArgParser(int argc, char *argv[]);
    void parse();
    bool argExists(const string &arg);
    vector<string> getArgValues();
    string returnFilepath();
};


