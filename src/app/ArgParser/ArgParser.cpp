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
#include <regex>
#include <limits>
#include <iomanip>

#include "ArgParser.h"
#include "crypto-encode/base58.h"
#include "crypto-encode/hex.h"
#include "crypto-hash/sha256.h"


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


/**
 * Implements sha256 hashing
 * @param value value to be hashed
 * @return hashed string
 */
string ArgParser::sha256(const string &value) {
    using safeheron::hash::CSHA256;

    CSHA256 sha256;
    uint8_t outputBuffer[CSHA256::OUTPUT_SIZE];
    sha256.Write(reinterpret_cast<const unsigned char*>(value.c_str()), value.length());
    sha256.Finalize(outputBuffer);

    ostringstream hexStream;
    for (unsigned char ch : outputBuffer) {
        hexStream << hex << setw(2) << setfill('0') << static_cast<int>(ch);
    }

    return hexStream.str();
}



/**
 * Parses the provided key value.
 *
 * Valid seed {value} is a byte sequence of length between 128 and 512 bits represented as case-insensitive hexadecimal values. Single space character ' ' or a
 * tab value '\t' can be used to separate the individual hexadecimal values. Note that extended public and private keys cannot be split by any whitespace.
 * The allowed seed lengths can be further constrained by the underlying BIP 32 library that you are using --- if so, mention the valid lengths in the help and
 * the project's README file.
 *
 * @param value value to be checked
 */
void ArgParser::parseDeriveKeyValue(const string &value) {
    const regex valueRegex("^((\\d|[a-f]|[A-F]){2}(\\s?|\\t?)){16,64}$");

    smatch matches;
    if (!regex_match(value, matches, valueRegex))
        throw invalid_argument("[ERROR]: parseDeriveKeyValue: invalid key value");

}


 /**
  * Parses the provided filepath, returns false if invalid, true if all good.
  *
  * The {path} value is a sequence of /NUM and /NUMh, where NUM is from the range [0,...,2^31-1] as described in BIP 32.
  * The path does not need to start with /. In the hardened version /NUMh the h indentifier can also be substituted with H or ' and these can also be
  * mixed within a single path. Parsing and normalizing the {path} value correctly for the underlying library is your task, however correctness of the
  * {path} is left to the library.
  *
  * @param filepath filepath to be checked
  */
void ArgParser::parseFilepath(const string &filepath) {
    const regex filepathRegex("^(\\/?\\d+(H|h|')?)+$");
    const regex numberRegex("\\d+");

    smatch matches;
    if (!regex_match(filepath, matches, filepathRegex))
        throw invalid_argument("[ERROR]: parseFilepath: filepathRegex did not match");

    const sregex_token_iterator end;
    for (sregex_token_iterator iter(filepath.begin(), filepath.end(), numberRegex, 0); iter != end; iter++) {
        try {
            unsigned long numBuffer = stoul(iter->str());

            if ((numeric_limits<uint32_t>::max() / 2) < numBuffer)
                throw out_of_range("[ERROR]: parseFilepath: Number above range");
        }
        catch (const out_of_range &e) {
            throw  invalid_argument("[ERROR]: parseFilepath: stoul failed");
        }
    }
}



/**
 * Converts WIF key to PK via base58 decoding. NOTE, that the fist byte is not dropped, as it should be
 * @param WIFKey WIF key to be converted
 * @return decoded PK
 */
string ArgParser::WIFToPrivateKey(const string &WIFKey) {
    using namespace safeheron::encode::hex;
    using namespace safeheron::encode::base58;
    string convertedString;
    try {
        convertedString = EncodeToHex(DecodeFromBase58(WIFKey));
    }
    catch (exception &ex) {
        throw invalid_argument("[ERROR]: WIFToPrivateKey: DecodeFromBase58 failed");
    }

    if (convertedString.length() != 74)
        throw invalid_argument("[ERROR]: WIFToPrivateKey: Invalid convertedString output length");

    return convertedString;
}



/**
 * Checks the WIF key's checksum
 * @param WIFKey WIF key to be checked
 * @return true if OK, false if otherwise
 */
void ArgParser::checkWIFChecksum(const string &WIFKey) {
    using namespace safeheron::encode::hex;
    using namespace safeheron::encode::base58;
    string convertedString;
    try {
        convertedString = WIFToPrivateKey(WIFKey);
    }
    catch (exception &ex) {
        throw_with_nested(invalid_argument("[ERROR]: checkWIFChecksum: WIFToPrivateKey failed"));
    }

    string shortString = convertedString.substr(0, 66);
    string checksum = convertedString.substr(66, convertedString.length());
    string result = sha256(DecodeFromHex(sha256(DecodeFromHex(shortString))));

    if (checksum != result.substr(0, 8))
        throw invalid_argument("[ERROR]: checkWIFChecksum: checksum does not match WIF key");
}


/**
 * Parses the values provided in key-expression
 * @param value value to be checked
 */
void ArgParser::parseKeyExpressionValue(const string &value) {
    const regex simpleKeyExpressionValueRegex("^" + SIMPLE_KEY_EXPRESSION_VALUE_REGEX + "$");
    const regex WIFRegex("^" + WIF_REGEX + "$");
    const regex extendedPrivateKeys("^" + EXTENDED_PRIVATE_KEYS_REGEX + "$");

    smatch matches;
    if (regex_match(value, matches, simpleKeyExpressionValueRegex)) {
        return;
    }
    else if (regex_match(value, matches, WIFRegex)) {
        try {
            checkWIFChecksum(value);
        }
        catch (exception &ex) {
            throw_with_nested(invalid_argument("[ERROR]: parseKeyExpressionValue: checkWIFChecksum failed"));
        }
    }
    else if (regex_match(value, matches, extendedPrivateKeys)) {
        return;
    }
    else {
        throw invalid_argument("[ERROR]: parseKeyExpressionValue: unrecognizable key expression");
    }
}



/**
 * Parses the values provided in script-expression
 * @param value value to be checked
 */
void ArgParser::parseScriptExpressionValue(const string &value) {
    const regex pkRegex("^" + PK_REGEX + CHECKSUM_REGEX + "$");
    const regex pkhRegex("^" + PKH_REGEX + CHECKSUM_REGEX + "$");
    const regex multiRegex("^" + MULTI_REGEX + CHECKSUM_REGEX + "$");
    const regex shPkRegex("^" + SH_PK_REGEX + CHECKSUM_REGEX + "$");
    const regex shPkhRegex("^" + SH_PKH_REGEX + CHECKSUM_REGEX + "$");
    const regex shMultiRegex("^" + SH_MULTI_REGEX + CHECKSUM_REGEX + "$");
    const regex rawRegex("^" + RAW_REGEX + CHECKSUM_REGEX + "$");

    const string singleValueFilterRegexLeft = "\\((\\s|\\t)*";
    const string singleValueFilterRegexRight = "(\\s|\\t)*\\)";

    smatch matches;
    if (regex_match(value, matches, pkRegex) ||
            regex_match(value, matches, pkhRegex) ||
            regex_match(value, matches, shPkRegex) ||
            regex_match(value, matches, shPkhRegex)) {
        if (regex_search(value, matches, regex(singleValueFilterRegexLeft + SIMPLE_KEY_EXPRESSION_VALUE_REGEX + singleValueFilterRegexRight)) ||
                regex_search(value, matches, regex(singleValueFilterRegexLeft + WIF_REGEX + singleValueFilterRegexRight)) ||
                regex_search(value, matches, regex(singleValueFilterRegexLeft + EXTENDED_PRIVATE_KEYS_REGEX + singleValueFilterRegexRight))) {
            parseKeyExpressionValue(matches[0].str().substr(1, matches[0].length() - 1));  // also eliminating parentheses
        }
        else {
            throw invalid_argument("[ERROR]: parseScriptExpressionValue: value(s) match no known script-expression regex");
        }
    }
    else if (regex_match(value, matches, multiRegex) ||
            regex_match(value, matches, shMultiRegex)) {
        regex_search(value, matches, regex("\\d+"));
        string argAmountStr = matches[0];
        unsigned long caughtKeys = 0;  // for verification that the provided number matches the amount of values provided
        const regex simpleKeyIteratorRegex(SIMPLE_KEY_EXPRESSION_VALUE_REGEX);
        const regex WIFIteratorRegex(WIF_REGEX);
        const regex extendedPrivateKeyIteratorRegex(SIMPLE_KEY_EXPRESSION_VALUE_REGEX);
        const sregex_token_iterator end;
        // go through every possible combination, as values can be any of these
        for (sregex_token_iterator iter(value.begin(), value.end(), simpleKeyIteratorRegex, 0); iter != end; iter++) {
            caughtKeys++;
            parseKeyExpressionValue(iter->str());
        }
        for (sregex_token_iterator iter(value.begin(), value.end(), WIFIteratorRegex, 0); iter != end; iter++) {
            caughtKeys++;
            parseKeyExpressionValue(iter->str());
        }
        for (sregex_token_iterator iter(value.begin(), value.end(), extendedPrivateKeyIteratorRegex, 0); iter != end; iter++) {
            caughtKeys++;
            parseKeyExpressionValue(iter->str());
        }
        // compare number of caught key values to the actual number provided
        try {
            unsigned long numBuffer = stoul(argAmountStr);
            if (numBuffer != caughtKeys)
                throw out_of_range("[ERROR]: parseScriptExpressionValue: number of values and provided number differs");
        }
        catch (const out_of_range &e) {
            throw_with_nested(invalid_argument("[ERROR]: parseScriptExpressionValue: stoul failed"));
        }
        // dynamic regex for final format checking
        const regex finalFormatRegexCheck("\\((\\s|\\t)*\\d+(\\s|\\t)*(,(\\s|\\t)*(" + SIMPLE_KEY_EXPRESSION_VALUE_REGEX + "|" + WIF_REGEX + "|" + EXTENDED_PRIVATE_KEYS_REGEX + ")(\\s|\\t)*){" + to_string(caughtKeys) + "}\\)" + CHECKSUM_REGEX);
        if (!regex_search(value, matches, finalFormatRegexCheck))
            throw invalid_argument("[ERROR]: parseScriptExpressionValue: final formatting regex failed, invalid internal formatting");
    }
    else if (regex_match(value, matches, rawRegex)) {
        return;
    }
    else {
        throw invalid_argument("[ERROR]: parseScriptExpressionValue: value(s) match no known regex");
    }
}



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

    for (const auto& arg : argList) {
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

    for (const auto& arg : argList) {
        if (arg == "script-expression") {
            continue;
        }
        else if (!*verifyChecksumFlag && (arg == "--verify-checksum")) {
            this->verifyChecksumFlag = true;
        }
        else if (!*computeChecksumFlag && (arg == "--compute-checksum")) {
            this->computeChecksumFlag = true;
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

    if (!filepath.empty()) {
        try {
            parseFilepath(filepath);
        }
        catch (exception &ex) {
            throw_with_nested(invalid_argument("[ERROR]: parseDeriveKey: invalid filepath"));
        }
    }

    try {
        for (const auto &value : tmpArgValueVector)
            parseDeriveKeyValue(value);
    }
    catch (exception &ex) {
        throw_with_nested(invalid_argument("[ERROR]: parseDeriveKey: invalid value(s)"));
    }

    this->argValuesVector = tmpArgValueVector;
}


/**
 * Function parses key-expression key command arguments
 */
void ArgParser::parseKeyExpression() {
    vector<string> tmpArgValueVector;
    getKeyExpressionArgs(&tmpArgValueVector);

    try {
        for (const auto &value : tmpArgValueVector)
            parseKeyExpressionValue(value);
    }
    catch (exception &ex) {
        throw_with_nested(invalid_argument("[ERROR]: parseKeyExpression: parseKeyExpressionValue failed"));
    }
    // todo unicode values?

    this->argValuesVector = tmpArgValueVector;
}


/**
 * Function parses script-expression command arguments
 */
void ArgParser::parseScriptExpression() {
    vector<string> tmpArgValueVector;
    this->verifyChecksumFlag = false;
    this->computeChecksumFlag = false;
    getScriptExpressionArgs(&tmpArgValueVector, &verifyChecksumFlag, &computeChecksumFlag);

    try {
        for (const auto &value : tmpArgValueVector)
            parseScriptExpressionValue(value);
    }
    catch (exception &ex) {
        throw_with_nested(invalid_argument("[ERROR]: parseScriptExpression: parseScriptExpressionValue failed"));
    }

    this->argValuesVector = tmpArgValueVector;
}




/**
 * The main function for parsing all CLI arguments
 */
void ArgParser::parse() {

    if (argList.size() < 2)
        throw invalid_argument("Invalid number of arguments. (>2 needed)");

    if (argExists("--help"))
        printHelp();

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
    return this->argValuesVector;
}

/**
 * Public getter for parsed and validated filepath (if present)
 * @return filepath if provided
 */
string ArgParser::getFilepath() {
    return this->argFilepath;
}


/**
 * Public getter for the VerifyChecksum flag
 * @return true if argument is provided, false if otherwise
 */
bool ArgParser::getVerifyChecksumFlag() const {
    return this->verifyChecksumFlag;
}

/**
 * Public getter for the ComputeChecksum flag
 * @return true if argument is provided, false if otherwise
 */
bool ArgParser::getComputeChecksumFlag() const {
    return this->computeChecksumFlag;
}



void ArgParser::loadArguments(int argc, char **argv) {
    for (int x = 1; x < argc; x++) {
        if (strlen(argv[x]) > 1000)
            throw invalid_argument("[ERROR]: ArgParser: argument too large (bigger than 1000 characters)");

        this->argList.emplace_back(argv[x]);
    }
}


ArgParser::ArgParser() = default;



