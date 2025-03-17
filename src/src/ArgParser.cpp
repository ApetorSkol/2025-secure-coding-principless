//
// Created by Pospes on 15.03.2025.
//

#include <string>
#include <algorithm>
#include <iostream>
#include <exception>
#include "ArgParser.h"

using namespace std;


/*
 * Prints help
 */
void ArgParser::printHelp() {
    cout << "Help printed" << endl;

    exit(0);
}


/*
 * Checks if argument exists in the arglist
 */
bool ArgParser::argExists(const string &arg) {
    return find(this->argList.begin(), this->argList.end(), arg) != this->argList.end();
}



/*
 * Detects if more than one args of the provided string exist
 */
bool ArgParser::multipleArgsExist(const string &arg) {
    auto iter = find(this->argList.begin(), this->argList.end(), arg);
    if (iter == this->argList.end())
        return false;

    return find(next(iter), this->argList.end(), arg) != this->argList.end();
}


/*
 * Checks if more than one key argument is entered
 */
bool ArgParser::invalidKeyArgsAmount() {
    return multipleArgsExist("derive-key") ||
            multipleArgsExist("key-expression") ||
            multipleArgsExist("script-expression") ||
            multipleArgsExist("-") ||
            multipleArgsExist("--path");
}


/*
 * Checks that key arguments are 1st
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

/*
 * Returns derive-key args from CLI.
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




/*
 * Returns "key-expression" args from CLI.
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


/*
 * Returns "script-expression" args from CLI.
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



void ArgParser::parseDeriveKey() {
    vector<string> tmpArgValueVector;
    string filepath;
    getDeriveKeyArgs(&tmpArgValueVector, &filepath);

    // todo parse filepath
    // todo parse tmpArgValueVector or throw exception

    this->argValuesVector = tmpArgValueVector;
}

void ArgParser::parseKeyExpression() {
    vector<string> tmpArgValueVector;
    getKeyExpressionArgs(&tmpArgValueVector);

    // todo parse tmpArgValueVector or throw exception

    this->argValuesVector = tmpArgValueVector;
}

void ArgParser::parseScriptExpression() {
    vector<string> tmpArgValueVector;
    bool verifyChecksumFlag = false;
    bool computeChecksumFlag = false;
    getScriptExpressionArgs(&tmpArgValueVector, &verifyChecksumFlag, &computeChecksumFlag);

    // todo parse tmpArgValueVector or throw exception

    this->argValuesVector = tmpArgValueVector;
}





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




ArgParser::ArgParser(int argc, char **argv) {
    for (int x = 1; x < argc; x++)
        this->argList.emplace_back(argv[x]);
    /*
    for (const auto& arg : argList)
        cout << arg << endl;
    */
    this->parse();
}

