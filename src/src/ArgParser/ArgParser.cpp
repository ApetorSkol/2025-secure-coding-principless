/**
 * Project: PV286 2024/2025 Project
 * @file ArgParser.cpp
 * @author Pospíšil Zbyněk (xpospis)
 * @brief Implementation of CLI argument parser
 * @date 2025-03-15
 *
 * @copyright Copyright (c) 2025
 *
 */

#include <string>
#include <algorithm>
#include <iostream>
#include <exception>
#include "ArgParser.h"

using namespace std;


/**
 * Prints help
 */
void ArgParser::printHelp() {
    cout << "Help printed" << endl;

    exit(0);
}


 /**
  * Checks if argument exists in the arglist
  * @param arg argument to check
  * @return true if found, false if otherwise
  */
bool ArgParser::argExists(const string &arg) {
    return find(this->argList.begin(), this->argList.end(), arg) != this->argList.end();
}


/**
 * Detects if more than one args of the provided string exist
 * @param arg argument to check
 * @return true if multiples exist, false if otherwise
 */
bool ArgParser::multipleArgsExist(const string &arg) {
    auto iter = find(this->argList.begin(), this->argList.end(), arg);
    if (iter == this->argList.end())
        return false;

    return find(next(iter), this->argList.end(), arg) != this->argList.end();
}


/**
 * Checks if more than one key argument is entered
 * @return true if multiples are found, false if otherwise
 */
bool ArgParser::invalidKeyArgsAmount() {
    return multipleArgsExist("derive-key") ||
            multipleArgsExist("key-expression") ||
            multipleArgsExist("script-expression") ||
            multipleArgsExist("-") ||
            multipleArgsExist("--path");
}


/**
 * Checks that key arguments are 1st
 * @return true if key args are correct, false if otherwise
 */
bool ArgParser::invalidKeyArgsPosition() {
    return (argList.at(0) != "derive-key" && argList.at(0) != "key-expression" && argList.at(0) != "script-expression");
}



/*
 * Parses the provided filepath, returns false if invalid, true if all good
 */
/*
bool ArgParser::parseFilepath(const string &filepath) {
    (void)filepath;
    return true;
}
*/


/**
 * Returns derive-key args from CLI.
 * @param tmpArgValueVector empty vector, which function fills with detected expressions
 * @param filepath empty filepath, which function fills with detected filepath (if present)
 */
void ArgParser::getDeriveKeyArgs(vector<string> *tmpArgValueVector, string *filepath) {
    if (tmpArgValueVector == nullptr || filepath == nullptr)
        throw runtime_error("[ERROR]: getDeriveKeyArgs: nullptr provided");

    string tmpArgValue;  // for CLI value

    for (auto iter = argList.begin(); iter != argList.end(); iter = next(iter)) {
        if (*iter == "derive-key") {
            continue;
        }
        else if ((*filepath).empty() && (*iter == "--path") && (next(iter) != argList.end())) {
            iter = next(iter);
            *filepath = *iter;
        }
        else if (tmpArgValue.empty() && *iter != "-") {
            tmpArgValue = *iter;
        }
        else if ((*tmpArgValueVector).empty() && *iter == "-") {
            string line;
            while (getline(cin, line))
                (*tmpArgValueVector).push_back(line);
        }
        else {
            throw invalid_argument("[ERROR]: getDeriveKeyArgs: unsupported argument");
        }
    }
    // Primarily works with vector form
    if ((*tmpArgValueVector).empty())
        (*tmpArgValueVector).push_back(tmpArgValue);
}




/**
 * Returns "key-expression" args from CLI.
 * @param tmpArgValueVector empty vector, which function fills with detected expressions
 */
void ArgParser::getKeyExpressionArgs(vector<string> *tmpArgValueVector) {
    if (tmpArgValueVector == nullptr)
        throw runtime_error("[ERROR]: getKeyExpressionArgs: nullptr provided");

    string tmpArgValue;  // for CLI value

    for (auto arg : argList) {
        if (arg == "key-expression") {
            continue;
        }
        else if (tmpArgValue.empty() && arg != "-") {
            tmpArgValue = arg;
        }
        else if ((*tmpArgValueVector).empty() && arg == "-") {
            string line;
            while (getline(cin, line))
                (*tmpArgValueVector).push_back(line);
        }
        else {
            throw invalid_argument("[ERROR]: getKeyExpressionArgs: unsupported argument");
        }
    }
    // Primarily works with vector form
    if ((*tmpArgValueVector).empty())
        (*tmpArgValueVector).push_back(tmpArgValue);
}



/**
 * Returns "script-expression" args from CLI.
 * @param tmpArgValueVector empty vector, which function fills with detected expressions
 * @param verifyChecksumFlag false by default, set to true if such argument is found
 * @param computeChecksumFlag false by default, set to true if such argument is found
 */
void ArgParser::getScriptExpressionArgs(vector<string> *tmpArgValueVector, bool *verifyChecksumFlag, bool *computeChecksumFlag) {
    if (tmpArgValueVector == nullptr || verifyChecksumFlag == nullptr || computeChecksumFlag == nullptr)
        throw runtime_error("[ERROR]: getScriptExpressionArgs: nullptr provided");

    string tmpArgValue;  // for CLI value

    for (auto arg : argList) {
        if (arg == "script-expression") {
            continue;
        }
        else if (tmpArgValue.empty() && arg != "-") {
            tmpArgValue = arg;
        }
        else if ((*tmpArgValueVector).empty() && arg == "-") {
            string line;
            while (getline(cin, line))
                (*tmpArgValueVector).push_back(line);
        }
        else if (!*verifyChecksumFlag && (arg == "--verify-checksum")) {
            *verifyChecksumFlag = true;
        }
        else if (!*computeChecksumFlag && (arg == "--compute-checksum")) {
            *computeChecksumFlag = true;
        }
        else {
            throw invalid_argument("[ERROR]: getScriptExpressionArgs: unsupported argument");
        }
    }

    if (*verifyChecksumFlag && *computeChecksumFlag)
        throw invalid_argument("[ERROR]: getScriptExpressionArgs: use either verifyChecksumFlag or computeChecksumFlag");

    // Primarily works with vector form
    if ((*tmpArgValueVector).empty())
        (*tmpArgValueVector).push_back(tmpArgValue);
}


/**
 * Function parses derive-key command arguments
 */
void ArgParser::parseDeriveKey() {
    vector<string> tmpArgValueVector;
    string filepath;
    getDeriveKeyArgs(&tmpArgValueVector, &filepath);

    // todo parse filepath
    // todo parse tmpArgValueVector or throw exception

    this->argValuesVector = tmpArgValueVector;
}

/**
 * Function parses key-expression key command arguments
 */
void ArgParser::parseKeyExpression() {
    vector<string> tmpArgValueVector;
    getKeyExpressionArgs(&tmpArgValueVector);

    // todo parse tmpArgValueVector or throw exception

    this->argValuesVector = tmpArgValueVector;
}


/**
 * Function parses script-expression command arguments
 */
void ArgParser::parseScriptExpression() {
    vector<string> tmpArgValueVector;
    bool verifyChecksumFlag = false;
    bool computeChecksumFlag = false;
    getScriptExpressionArgs(&tmpArgValueVector, &verifyChecksumFlag, &computeChecksumFlag);

    // todo parse tmpArgValueVector or throw exception

    this->argValuesVector = tmpArgValueVector;
}




/**
 * The main function for parsing all CLI arguments
 */
void ArgParser::parse() {

    if (argList.size() < 2)
        throw invalid_argument("Invalid number of arguments. (>2 needed)");

    if (argExists("--help"))
        this->printHelp();

    if (invalidKeyArgsAmount())
        throw invalid_argument("Invalid number of key arguments");

    if (invalidKeyArgsPosition())
        throw invalid_argument("First argument must be key-argument");


    if (argExists("derive-key"))
        parseDeriveKey();
    else if (argExists("key-expression"))
        parseKeyExpression();
    else if (argExists("script-expression"))
        parseScriptExpression();
}


/**
 * Public getter for parsed and validated argument values
 * @return vector of argument values to perform operations on
 */
vector<string> ArgParser::getArgValues() {
    return this->argList;
}

/**
 * Public getter for parsed and validated filepath (if present)
 * @return filepath if provided
 */
string ArgParser::returnFilepath() {
    return this->argFilepath;
}


ArgParser::ArgParser(int argc, char **argv) {
    for (int x = 1; x < argc; x++)
        this->argList.emplace_back(argv[x]);
    /*
    for (const auto& arg : argList)
        cout << arg << endl;
    */
}

